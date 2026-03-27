# frozen_string_literal: true

require "nokogiri"

module Scraper
  module YarnSub
    class YarnList
      def initialize(client:)
        @client = client
      end

      def parse(brand_slug:)
        html = @client.get("#{Config::BASE_URL}/yarns/#{brand_slug}")
        doc = Nokogiri::HTML(html)

        doc.css("div.yarnList a, ul.yarnList li a").filter_map do |link|
          href = link["href"]
          next unless href&.include?("/yarns/#{brand_slug}/")

          slug = href.split("/").last
          next if slug.nil? || slug.empty?

          {name: link.text.strip, slug: slug}
        end.uniq { |y| y[:slug] }
      end
    end
  end
end
