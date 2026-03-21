require "simplecov"
require "simplecov-json"

SimpleCov.start do
  command_name "gauge-calculator"
  add_filter "/test/"
  add_filter "/vendor/"
  add_filter "/config/"
end

ENV["SINATRA_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "nokogiri"
require_relative "../config/environment"
require_relative "support/fiber_gauge_test_support"

class Minitest::Test
  include ClassMethodStubHelper

  def app
    GaugeCalculatorApp
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
end
