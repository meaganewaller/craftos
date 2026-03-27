# frozen_string_literal: true

require "nokogiri"
require_relative "base"

module Scraper
  module Colorways
    class Cascade < Base
      register "cascade"

      COLORWAY_URL = "https://www.cascadeyarns.com/product"

      def scrape(client:, brand_slug:, yarn_slug:)
        url = "#{COLORWAY_URL}/#{yarn_slug}"
        html = client.get(url)
        doc = Nokogiri::HTML(html)

        doc.css(".color-chip, .swatch, .colorway-item").filter_map do |el|
          name = el["title"] || el.css(".color-name, .name, span").first&.text
          next unless name && !name.strip.empty?

          img = el.at_css("img")
          swatch_url = img&.[]("src")

          {
            name: name.strip,
            color_family: classify_color(name),
            swatch_image_url: swatch_url
          }
        end
      rescue => e
        puts "  [Colorway] Cascade/#{yarn_slug} failed: #{e.message}"
        []
      end

      private

      def classify_color(name)
        downcased = name.downcase
        case downcased
        when /red|crim|scarlet|cherry/ then "red"
        when /blue|navy|sky|cobalt/ then "blue"
        when /green|emerald|sage|olive/ then "green"
        when /yellow|gold|honey|sun/ then "yellow"
        when /purple|violet|plum|lavender/ then "purple"
        when /orange|peach|tangerine/ then "orange"
        when /pink|rose|fuchsia|magenta/ then "pink"
        when /brown|chocolate|coffee|mocha/ then "brown"
        when /grey|gray|silver|charcoal/ then "gray"
        when /black|noir|ebony/ then "black"
        when /white|ivory|cream|natural/ then "white"
        else "multi"
        end
      end
    end
  end
end
