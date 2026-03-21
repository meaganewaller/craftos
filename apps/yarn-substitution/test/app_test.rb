# frozen_string_literal: true

require "test_helper"

class YarnSubstitutionAppTest < Minitest::Test
  def test_get_root_returns_200
    request_get "/"

    assert last_response.ok?
  end

  def test_get_root_renders_form
    request_get "/"

    assert_includes last_response.body, "yarn substitution finder"
    assert_includes last_response.body, "yardage"
  end

  def test_serves_css
    request_get "/css/app.css"

    assert last_response.ok?
  end

  def test_serves_js
    request_get "/js/substitute.js"

    assert last_response.ok?
  end
end
