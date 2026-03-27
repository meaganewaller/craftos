# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class HttpClientTest < Minitest::Test
  def setup
    @cache_dir = File.join(Dir.tmpdir, "scraper_test_cache_#{$$}")
    FileUtils.mkdir_p(@cache_dir)
  end

  def teardown
    FileUtils.rm_rf(@cache_dir)
  end

  def test_caches_responses
    client = Scraper::HttpClient.new(delay: 0, cache_dir: @cache_dir)

    url = "https://example.com/test"
    cache_key = Digest::SHA256.hexdigest(url)
    File.write(File.join(@cache_dir, cache_key), "<html>cached</html>")

    result = client.get(url)
    assert_equal "<html>cached</html>", result
  end

  def test_cache_key_is_sha256_of_url
    client = Scraper::HttpClient.new(delay: 0, cache_dir: @cache_dir)
    url = "https://yarnsub.com/yarns"
    expected_key = Digest::SHA256.hexdigest(url)

    File.write(File.join(@cache_dir, expected_key), "test body")

    assert_equal "test body", client.get(url)
  end
end
