require "test_helper"

class GaugeCalculatorAppTest < Minitest::Test
  def test_get_root_renders_the_gauge_calculator_page
    request_get "/"

    assert last_response.ok?
    assert_equal "Gauge Calculator ✿", html.at("title").text
    assert_match(/gauge calculator/i, html.at("h1").text)
    unit_select = html.at_css("select#unit")
    assert unit_select, "expected a unit select element"
    options = unit_select.css("option").map { |o| o["value"] }
    assert_equal %w[inches centimeters], options
    assert_equal "18", html.at_css("input#stitches")["value"]
    assert_equal "24", html.at_css("input#rows")["value"]
    assert_equal "4", html.at_css("input#width")["value"]
    assert_equal "38", html.at_css("input#targetWidth")["value"]
    assert_equal "optional", html.at_css("input#repeat")["placeholder"]
    assert_equal "0", html.at_css("input#offset")["value"]
    assert_equal "10", html.at_css("input#targetHeight")["value"]
    assert_includes last_response.body, "calculate my gauge!"
    assert_includes last_response.body, "calculate stitches"
    assert_includes last_response.body, "calculate rows"
  end

  def test_get_root_includes_external_assets
    request_get "/"

    assert last_response.ok?
    assert html.at_css('script[src="/js/gauge.js"]'), "expected gauge.js script tag"
    assert html.at_css('link[href="/css/app.css"]'), "expected app.css link tag"
    assert html.at_css("#errorBanner"), "expected an error banner element"
  end

  def test_gauge_js_is_served_as_static_asset
    request_get "/js/gauge.js"

    assert last_response.ok?
    assert_includes last_response.body, "function apiPost("
    assert_includes last_response.body, "function calculateGauge()"
    assert_includes last_response.body, "function calculateStitches()"
    assert_includes last_response.body, "function calculateRows()"
  end

  def test_app_css_is_served_as_static_asset
    request_get "/css/app.css"

    assert last_response.ok?
    assert_includes last_response.body, ".tooltip"
  end
end
