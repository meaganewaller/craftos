# frozen_string_literal: true

require "digest"
require "fileutils"
require "net/http"
require "uri"

module Scraper
  class HttpClient
    MAX_RETRIES = 2

    def initialize(delay: Config::DELAY_SECONDS, cache_dir: Config::CACHE_DIR, user_agent: Config::USER_AGENT)
      @delay = delay
      @cache_dir = cache_dir
      @user_agent = user_agent
      @last_request_at = nil
      FileUtils.mkdir_p(@cache_dir)
    end

    def get(url)
      cached = read_cache(url)
      return cached if cached

      throttle
      body = fetch_with_retries(url)
      write_cache(url, body)
      body
    end

    private

    def throttle
      if @last_request_at
        elapsed = Time.now - @last_request_at
        sleep(@delay - elapsed) if elapsed < @delay
      end
      @last_request_at = Time.now
    end

    def fetch_with_retries(url, attempt: 0)
      uri = URI.parse(url)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = @user_agent
        http.request(request)
      end

      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        fetch_with_retries(response["location"], attempt: attempt)
      else
        raise "HTTP #{response.code} for #{url}" if attempt >= MAX_RETRIES
        sleep(2**attempt)
        fetch_with_retries(url, attempt: attempt + 1)
      end
    end

    def cache_key(url)
      Digest::SHA256.hexdigest(url)
    end

    def cache_path(url)
      File.join(@cache_dir, cache_key(url))
    end

    def read_cache(url)
      path = cache_path(url)
      File.read(path) if File.exist?(path)
    end

    def write_cache(url, body)
      File.write(cache_path(url), body)
    end
  end
end
