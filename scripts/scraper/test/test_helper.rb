# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "scraper"
require "minitest/autorun"

module Scraper
  class StubClient
    def initialize(fixtures = {})
      @fixtures = fixtures
    end

    def get(url)
      @fixtures[url] || raise("No fixture for #{url}")
    end
  end
end
