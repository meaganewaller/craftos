require "simplecov"
require "simplecov-json"

SimpleCov.start do
  command_name "pattern-editor"
  add_filter "/test/"
  add_filter "/vendor/"
  add_filter "/config/"
end

ENV["SINATRA_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "nokogiri"
require_relative "../config/environment"

class Minitest::Test
  def app
    PatternEditorApp
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

  def last_response
    rack_test_session.last_response
  end

  def html
    Nokogiri::HTML(last_response.body)
  end

  def json_response
    JSON.parse(last_response.body)
  end

  def post_json(path, body)
    request_post path, JSON.generate(body), {"CONTENT_TYPE" => "application/json"}
  end
end
