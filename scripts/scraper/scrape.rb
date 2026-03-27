#!/usr/bin/env ruby
# frozen_string_literal: true

require "dotenv"
Dotenv.load(File.expand_path("../../.env", __dir__))
require_relative "lib/scraper"

dry_run = ARGV.include?("--dry-run")

client = Scraper::HttpClient.new
uploader = Scraper::R2Uploader.new
exporter = Scraper::YamlExporter.new(output_dir: File.expand_path("../../data/yarns", __dir__))

brand_list = Scraper::YarnSub::BrandList.new(client: client)
yarn_list = Scraper::YarnSub::YarnList.new(client: client)
yarn_detail = Scraper::YarnSub::YarnDetail.new(client: client)

brands = brand_list.parse
puts "Found #{brands.size} matching brands"

total_yarns = 0
total_images = 0

brands.each do |brand|
  puts "\nProcessing #{brand[:name]} (#{brand[:slug]})..."
  yarns = yarn_list.parse(brand_slug: brand[:slug])
  puts "  Found #{yarns.size} yarn lines"

  details = yarns.filter_map do |yarn|
    puts "  Fetching #{yarn[:name]}..."
    detail = yarn_detail.parse(brand_slug: brand[:slug], yarn_slug: yarn[:slug])

    if detail[:yardage].nil? || detail[:skein_weight].nil?
      puts "    Skipping #{yarn[:name]} (missing yardage or weight)"
      next
    end

    # Upload image to R2 if available
    if detail[:image_url] && !dry_run
      ext = File.extname(detail[:image_url]).split("?").first
      ext = ".jpg" if ext.empty?
      r2_key = "yarn-images/#{brand[:slug]}/#{detail[:slug]}#{ext}"

      r2_url = uploader.upload_from_url(
        url: detail[:image_url],
        key: r2_key,
        http_client: client
      )

      if r2_url
        detail[:image_url] = r2_url
        total_images += 1
      end
    end

    detail
  end

  total_yarns += details.size

  if dry_run
    puts "  [DRY RUN] Would write #{details.size} yarns to data/yarns/#{brand[:slug]}.yml"
  else
    path = exporter.export_brand(brand_name: brand[:name], brand_slug: brand[:slug], yarns: details)
    puts "  Wrote #{details.size} yarns to #{path}"
  end
end

unless dry_run
  exporter.export_meta(brands_count: brands.size, yarns_count: total_yarns)
end

puts "\nDone! #{brands.size} brands, #{total_yarns} yarns, #{total_images} images uploaded"
