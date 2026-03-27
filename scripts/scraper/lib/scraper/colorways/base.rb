# frozen_string_literal: true

module Scraper
  module Colorways
    class Base
      @registry = {}

      class << self
        attr_reader :registry

        def register(brand_slug)
          Base.registry[brand_slug] = self
        end

        def for(brand_slug)
          klass = registry[brand_slug]
          klass&.new
        end
      end

      def initialize
        # subclasses can override
      end

      def scrape(client:, brand_slug:, yarn_slug:)
        raise NotImplementedError, "#{self.class}#scrape must be implemented"
      end
    end
  end
end
