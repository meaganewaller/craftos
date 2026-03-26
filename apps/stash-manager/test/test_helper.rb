require "simplecov"
require "simplecov-json"

SimpleCov.start do
  command_name "stash-manager"
  add_filter "/test/"
  add_filter "/vendor/"
  add_filter "/config/"
  add_filter "/db/"
end

ENV["SINATRA_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require_relative "../config/environment"

class Minitest::Test
  def app
    StashManagerApp
  end

  def rack_test_session
    @rack_test_session ||= Rack::Test::Session.new(Rack::MockSession.new(app))
  end

  def request_get(path, headers = {})
    rack_test_session.get(path, {}, headers)
  end

  def request_post(path, body = nil, headers = {})
    rack_test_session.post(path, body, headers)
  end

  def request_delete(path, headers = {})
    rack_test_session.delete(path, {}, headers)
  end

  def last_response
    rack_test_session.last_response
  end

  def json_response
    JSON.parse(last_response.body)
  end

  def setup
    StashEntry.dataset.delete
    User.dataset.delete
  end

  def create_user(username: "testuser", password: "password123")
    user = User.new(username: username)
    user.password = password
    user.save
    user
  end

  def login_as(user, password: "password123")
    request_post "/api/auth/login",
      JSON.generate({username: user.username, password: password}),
      {"CONTENT_TYPE" => "application/json"}
  end

  def create_and_login(username: "testuser", password: "password123")
    user = create_user(username: username, password: password)
    login_as(user, password: password)
    user
  end
end
