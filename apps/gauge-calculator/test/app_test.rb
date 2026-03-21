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

  def test_get_root_includes_javascript_hooks_for_the_gauge_endpoints
    request_get "/"

    assert last_response.ok?
    assert_includes last_response.body, 'fetch("/api/gauge"'
    assert_includes last_response.body, 'fetch("/api/gauge/stitches"'
    assert_includes last_response.body, 'fetch("/api/gauge/rows"'
    assert_includes last_response.body, 'document.getElementById("spi").innerText = data.spi'
    assert_includes last_response.body, "let base = data.stitches"
    assert_includes last_response.body, "if (repeat)"
    assert_includes last_response.body, '`${base} -> ${adjusted} (adjusted)`'
    assert_includes last_response.body, 'document.getElementById("rowResult").innerText = data.rows'
    assert_includes last_response.body, "function getUnit()"
    assert_includes last_response.body, "function updateUnitLabels()"
  end
end
