# frozen_string_literal: true

require "test_helper"

class MalabrigoColorwayTest < Minitest::Test
  def test_registered_for_malabrigo
    scraper = Scraper::Colorways::Base.for("malabrigo")
    assert_instance_of Scraper::Colorways::Malabrigo, scraper
  end

  def test_returns_empty_array_on_error
    client = Scraper::StubClient.new({})

    # Will raise because no fixture matches
    scraper = Scraper::Colorways::Malabrigo.new
    result = scraper.scrape(client: client, brand_slug: "malabrigo", yarn_slug: "rios")

    assert_equal [], result
  end

  def test_parses_colorway_data
    html = <<~HTML
      <html><body>
      <div class="color-swatch" data-color="Azules">
        <img src="https://example.com/azules.jpg" />
      </div>
      <div class="color-swatch" data-color="Ravelry Red">
        <img src="https://example.com/red.jpg" />
      </div>
      </body></html>
    HTML

    client = Scraper::StubClient.new("https://malabrigoyarn.com/yarns/rios" => html)
    scraper = Scraper::Colorways::Malabrigo.new
    result = scraper.scrape(client: client, brand_slug: "malabrigo", yarn_slug: "rios")

    assert_equal 2, result.size
    assert_equal "Azules", result[0][:name]
    assert_equal "blue", result[0][:color_family]
    assert_equal "Ravelry Red", result[1][:name]
    assert_equal "red", result[1][:color_family]
  end
end
