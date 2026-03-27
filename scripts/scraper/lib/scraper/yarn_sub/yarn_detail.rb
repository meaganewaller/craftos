# frozen_string_literal: true

require "nokogiri"

module Scraper
  module YarnSub
    class YarnDetail
      def initialize(client:)
        @client = client
      end

      def parse(brand_slug:, yarn_slug:)
        url = "#{Config::BASE_URL}/yarns/#{brand_slug}/#{yarn_slug}"
        html = @client.get(url)
        doc = Nokogiri::HTML(html)

        balls_text = extract_field(doc, "Balls")
        yardage, skein_weight = parse_balls(balls_text)

        {
          slug: yarn_slug,
          line: extract_text(doc, "h2, h1") || yarn_slug,
          weight_category: extract_weight_category(doc),
          fiber_content: extract_fiber_content(doc),
          yardage: yardage,
          skein_weight: skein_weight,
          texture: extract_field(doc, "Texture"),
          gauge: extract_field(doc, "Gauge"),
          needle_size: extract_field(doc, "Needles"),
          style_categories: extract_styles(doc),
          image_url: extract_image(doc)
        }
      end

      private

      def extract_text(doc, selector)
        node = doc.at_css(selector)
        node&.text&.strip
      end

      def extract_field(doc, label)
        row = doc.css("table.details tr").detect { |tr|
          th = tr.at_css("th")
          th&.text&.include?(label)
        }
        return nil unless row

        row.at_css("td")&.text&.strip
      end

      def extract_weight_category(doc)
        value = extract_field(doc, "Weight")
        return nil unless value

        # "Worsted / Medium" -> "Worsted"
        value.split("/").first&.strip
      end

      def parse_balls(text)
        return [nil, nil] unless text

        # "100 g; 192 m (210 yds)"
        weight = text.scan(/([\d.]+)\s*g/).flatten.first&.to_i
        yardage = text.scan(/([\d.]+)\s*yds/).flatten.first&.to_i
        yardage ||= text.scan(/([\d.]+)\s*m\b/).flatten.first&.to_i

        [yardage, weight]
      end

      def extract_fiber_content(doc)
        content = {}
        text = extract_field(doc, "Fiber")
        return content unless text

        # "Merino Superwash Wool (100%)" or "Wool (80%), Nylon (20%)"
        text.scan(/([^,(]+?)\s*\(([\d.]+)%\)/).each do |fiber, pct|
          content[fiber.strip.downcase.gsub(/\s+/, "_")] = pct.to_i
        end

        content
      end

      def extract_styles(doc)
        value = extract_field(doc, "Styles")
        return [] unless value

        value.split(",").map(&:strip).reject(&:empty?)
      end

      def extract_image(doc)
        img = doc.at_css("img.yarnImage") || doc.at_css("img[src*='/articles/reviews/']")
        return nil unless img

        src = img["src"]
        src&.start_with?("http") ? src : "#{Config::BASE_URL}#{src}"
      end
    end
  end
end
