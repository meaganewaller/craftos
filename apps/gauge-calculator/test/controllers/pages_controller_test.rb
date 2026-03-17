require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders the gauge calculator page" do
    get root_path

    assert_response :success
    assert_select "title", text: "Gauge Calculator ✿"
    assert_select "h1", text: /gauge calculator/i
    assert_select "input#stitches[value='18']"
    assert_select "input#rows[value='24']"
    assert_select "input#width[value='4']"
    assert_select "input#targetWidth[value='38']"
    assert_select "input#repeat[placeholder='optional']"
    assert_select "input#offset[value='0']"
    assert_select "button", text: /calculate my gauge!/i
    assert_select "button", text: /calculate stitches/i
  end

  test "GET / includes javascript hooks for the gauge endpoints" do
    get root_path

    assert_response :success
    assert_includes response.body, 'fetch("/api/gauge"'
    assert_includes response.body, 'fetch("/api/gauge/stitches"'
    assert_includes response.body, 'document.getElementById("spi").innerText = data.spi'
    assert_includes response.body, "let base = data.stitches"
    assert_includes response.body, "if (repeat)"
    assert_includes response.body, 'repeat'
    assert_includes response.body, '`${base} → ${adjusted} (adjusted)`'
  end
end
