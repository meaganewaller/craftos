# frozen_string_literal: true

require "test_helper"

class BrandListTest < Minitest::Test
  def test_parses_brands_from_first_list_only
    html = File.read(File.expand_path("../../fixtures/yarnsub/brands.html", __dir__))
    client = Scraper::StubClient.new("#{Scraper::Config::BASE_URL}/yarns" => html)
    parser = Scraper::YarnSub::BrandList.new(client: client)

    brands = parser.parse

    assert_equal 2, brands.size
    slugs = brands.map { |b| b[:slug] }
    assert_includes slugs, "malabrigo_yarn"
    assert_includes slugs, "cascade_yarns"
    refute_includes slugs, "other_brand"
  end
end
