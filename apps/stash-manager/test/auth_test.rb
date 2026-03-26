# frozen_string_literal: true

require "test_helper"

class AuthTest < Minitest::Test
  def post_json(path, body)
    request_post path,
      JSON.generate(body),
      {"CONTENT_TYPE" => "application/json"}
  end

  # --- Signup ---

  def test_signup_creates_user
    post_json "/api/auth/signup", {username: "alice", password: "password123"}

    assert last_response.ok?
    data = json_response
    assert_equal "alice", data["user"]["username"]
    assert User.where(username: "alice").any?
  end

  def test_signup_rejects_duplicate_username
    create_user(username: "alice")
    post_json "/api/auth/signup", {username: "alice", password: "password123"}

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "already taken"
  end

  def test_signup_rejects_short_password
    post_json "/api/auth/signup", {username: "alice", password: "short"}

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "at least 8"
  end

  def test_signup_rejects_blank_username
    post_json "/api/auth/signup", {username: "", password: "password123"}

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "required"
  end

  # --- Login ---

  def test_login_succeeds_with_valid_credentials
    create_user(username: "alice", password: "password123")
    post_json "/api/auth/login", {username: "alice", password: "password123"}

    assert last_response.ok?
    assert_equal "alice", json_response["user"]["username"]
  end

  def test_login_fails_with_wrong_password
    create_user(username: "alice", password: "password123")
    post_json "/api/auth/login", {username: "alice", password: "wrong"}

    assert_equal 401, last_response.status
    assert_includes json_response["error"], "Invalid"
  end

  def test_login_fails_with_nonexistent_user
    post_json "/api/auth/login", {username: "nobody", password: "password123"}

    assert_equal 401, last_response.status
  end

  # --- Session ---

  def test_session_returns_user_when_logged_in
    create_and_login(username: "alice")
    request_get "/api/auth/session"

    assert last_response.ok?
    assert_equal "alice", json_response["user"]["username"]
  end

  def test_session_returns_401_when_not_logged_in
    request_get "/api/auth/session"

    assert_equal 401, last_response.status
  end

  # --- Logout ---

  def test_logout_clears_session
    create_and_login(username: "alice")
    request_post "/logout"

    # After logout, session endpoint should return 401
    request_get "/api/auth/session"
    assert_equal 401, last_response.status
  end

  # --- Access control ---

  def test_api_stash_returns_401_without_session
    request_get "/api/stash"

    assert_equal 401, last_response.status
  end

  def test_root_redirects_to_login_without_session
    request_get "/"

    assert_equal 302, last_response.status
    assert_includes last_response.headers["Location"], "/login"
  end

  def test_login_page_accessible_without_session
    request_get "/login"

    assert last_response.ok?
    assert_includes last_response.body, "Log In"
  end

  def test_signup_page_accessible_without_session
    request_get "/signup"

    assert last_response.ok?
    assert_includes last_response.body, "Sign Up"
  end

  # --- User isolation ---

  def test_users_cannot_see_each_others_entries
    # User A creates an entry
    create_and_login(username: "alice")
    request_post "/api/stash",
      JSON.generate({brand: "Malabrigo", line: "Rios", yardage: 210, skein_weight: 100, quantity: 1}),
      {"CONTENT_TYPE" => "application/json"}
    assert_equal 201, last_response.status

    # Switch to User B
    @rack_test_session = nil
    create_and_login(username: "bob")
    request_get "/api/stash"

    assert last_response.ok?
    assert_equal [], json_response
  end

  def test_user_cannot_delete_another_users_entry
    # User A creates an entry
    create_and_login(username: "alice")
    request_post "/api/stash",
      JSON.generate({brand: "Malabrigo", line: "Rios", yardage: 210, skein_weight: 100, quantity: 1}),
      {"CONTENT_TYPE" => "application/json"}
    id = json_response["id"]

    # Switch to User B
    @rack_test_session = nil
    create_and_login(username: "bob")
    request_delete "/api/stash/#{id}"

    assert_equal 404, last_response.status
  end
end
