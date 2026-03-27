# frozen_string_literal: true

require "test_helper"

class YarnListTest < Minitest::Test
  def test_parses_yarn_lines_for_brand
    html = File.read(File.expand_path("../../fixtures/yarnsub/malabrigo_yarns.html", __dir__))
    client = Scraper::StubClient.new("#{Scraper::Config::BASE_URL}/yarns/malabrigo_yarn" => html)
    parser = Scraper::YarnSub::YarnList.new(client: client)

    yarns = parser.parse(brand_slug: "malabrigo_yarn")

    assert_equal 2, yarns.size
    assert_equal "rios", yarns[0][:slug]
    assert_equal "mechita", yarns[1][:slug]
  end
end
