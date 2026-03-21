require "simplecov"
require "simplecov-json"

SimpleCov.start do
  command_name "yarn-substitution"
  add_filter "/test/"
  add_filter "/vendor/"
  add_filter "/config/"
end

ENV["SINATRA_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require_relative "../config/environment"
require_relative "support/yarn_skein_test_support"

class Minitest::Test
  include ClassMethodStubHelper

  def app
    YarnSubstitutionApp
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

  def json_response
    JSON.parse(last_response.body)
  end
end
