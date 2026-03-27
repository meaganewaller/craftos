# frozen_string_literal: true

require "nokogiri"

module Scraper
  module YarnSub
    class BrandList
      def initialize(client:)
        @client = client
      end

      def parse
        html = @client.get("#{Config::BASE_URL}/yarns")
        doc = Nokogiri::HTML(html)

        # The first ul.brandList is "Most popular brands" (top tier)
        top_list = doc.at_css("ul.brandList")
        return [] unless top_list

        top_list.css("li a").filter_map do |link|
          slug = link["href"]&.sub(%r{^/yarns/}, "")&.chomp("/")
          next unless slug && !slug.empty?

          {name: link.text.strip, slug: slug}
        end
      end
    end
  end
end
