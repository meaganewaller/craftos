# frozen_string_literal: true

require "test_helper"

class YarnDetailTest < Minitest::Test
  def test_parses_yarn_detail_page
    html = File.read(File.expand_path("../../fixtures/yarnsub/malabrigo_rios.html", __dir__))
    url = "#{Scraper::Config::BASE_URL}/yarns/malabrigo_yarn/rios"
    client = Scraper::StubClient.new(url => html)
    parser = Scraper::YarnSub::YarnDetail.new(client: client)

    detail = parser.parse(brand_slug: "malabrigo_yarn", yarn_slug: "rios")

    assert_equal "rios", detail[:slug]
    assert_equal "Rios", detail[:line]
    assert_equal "Worsted", detail[:weight_category]
    assert_equal 210, detail[:yardage]
    assert_equal 100, detail[:skein_weight]
    assert_equal({"merino_superwash_wool" => 100}, detail[:fiber_content])
    assert_equal "Plied (3 or more plies)", detail[:texture]
    assert_equal "18–22 sts / 10 cm (4\")", detail[:gauge]
    assert_equal "4 mm (6 US) (8 UK), 5 mm (8 US) (6 UK)", detail[:needle_size]
    assert_equal ["Tonal colors", "Multicolored"], detail[:style_categories]
    assert_equal "#{Scraper::Config::BASE_URL}/articles/reviews/malabrigo_yarn/rios.jpg", detail[:image_url]
  end
end
