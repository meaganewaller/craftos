# frozen_string_literal: true

require "yaml"
require "fileutils"

module Scraper
  class YamlExporter
    def initialize(output_dir:)
      @output_dir = output_dir
      FileUtils.mkdir_p(@output_dir)
    end

    def export_brand(brand_name:, brand_slug:, yarns:)
      data = {
        "brand" => brand_name,
        "slug" => brand_slug,
        "yarns" => yarns.map { |y| format_yarn(y) }
      }

      path = File.join(@output_dir, "#{brand_slug}.yml")
      File.write(path, YAML.dump(data))
      path
    end

    def export_meta(brands_count:, yarns_count:)
      meta = {
        "scraped_at" => Time.now.utc.iso8601,
        "version" => "1.0",
        "brands_count" => brands_count,
        "yarns_count" => yarns_count
      }

      path = File.join(@output_dir, "_meta.yml")
      File.write(path, YAML.dump(meta))
      path
    end

    private

    def format_yarn(yarn)
      {
        "line" => yarn[:line],
        "slug" => yarn[:slug],
        "weight_category" => yarn[:weight_category],
        "yardage" => yarn[:yardage],
        "skein_weight" => yarn[:skein_weight],
        "fiber_content" => yarn[:fiber_content],
        "texture" => yarn[:texture],
        "gauge" => yarn[:gauge],
        "needle_size" => yarn[:needle_size],
        "style_categories" => yarn[:style_categories] || [],
        "image_url" => yarn[:image_url],
        "colorways" => []
      }
    end
  end
end
