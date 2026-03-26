# frozen_string_literal: true

require "test_helper"

class StashManagerAppTest < Minitest::Test
  def setup
    super
    @user = create_and_login
  end

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

  def test_unauthenticated_root_redirects_to_login
    rack_test_session.clear_cookies
    @rack_test_session = nil
    request_get "/"

    assert_equal 302, last_response.status
    assert_includes last_response.headers["Location"], "/login"
  end
end
