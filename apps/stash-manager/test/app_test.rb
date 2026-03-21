# frozen_string_literal: true

require "test_helper"

class StashManagerAppTest < Minitest::Test
  def test_get_root_returns_200
    request_get "/"

    assert last_response.ok?
  end

  def test_get_root_renders_stash_page
    request_get "/"

    assert_includes last_response.body, "yarn stash manager"
  end

  def test_serves_css
    request_get "/css/app.css"

    assert last_response.ok?
  end

  def test_serves_js
    request_get "/js/stash.js"

    assert last_response.ok?
  end
end
