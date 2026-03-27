# frozen_string_literal: true

require "test_helper"

class R2UploaderTest < Minitest::Test
  def test_returns_nil_when_no_client_configured
    uploader = Scraper::R2Uploader.new(client: nil)

    assert_nil uploader.upload(key: "test/image.jpg", body: "data")
  end

  def test_uploads_new_object
    mock_client = MockS3Client.new(exists: false)
    uploader = Scraper::R2Uploader.new(client: mock_client)

    url = uploader.upload(key: "yarn-images/test/image.jpg", body: "imagedata")

    assert mock_client.put_called
    assert_match(/yarn-images\/test\/image\.jpg/, url)
  end

  def test_skips_existing_object
    mock_client = MockS3Client.new(exists: true)
    uploader = Scraper::R2Uploader.new(client: mock_client)

    uploader.upload(key: "yarn-images/test/image.jpg", body: "imagedata")

    refute mock_client.put_called
  end

  class MockS3Client
    attr_reader :put_called

    def initialize(exists: false)
      @exists = exists
      @put_called = false
    end

    def head_object(bucket:, key:)
      raise Aws::S3::Errors::NotFound.new(nil, "not found") unless @exists
      true
    end

    def put_object(bucket:, key:, body:, content_type:)
      @put_called = true
    end
  end
end
