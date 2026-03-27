# frozen_string_literal: true

require "aws-sdk-s3"

module Scraper
  class R2Uploader
    def initialize(client: nil)
      @client = client || build_client
    end

    def upload(key:, body:, content_type: "image/jpeg")
      return nil unless @client

      if exists?(key)
        puts "  [R2] Already exists: #{key}"
        return public_url(key)
      end

      @client.put_object(
        bucket: Config::R2_BUCKET,
        key: key,
        body: body,
        content_type: content_type
      )

      puts "  [R2] Uploaded: #{key}"
      public_url(key)
    end

    def upload_from_url(url:, key:, http_client:)
      return nil unless @client && url

      body = http_client.get(url)
      content_type = url.end_with?(".png") ? "image/png" : "image/jpeg"
      upload(key: key, body: body, content_type: content_type)
    end

    private

    def exists?(key)
      @client.head_object(bucket: Config::R2_BUCKET, key: key)
      true
    rescue Aws::S3::Errors::NotFound
      false
    end

    def public_url(key)
      "#{Config::R2_PUBLIC_URL}/#{key}"
    end

    def build_client
      return nil unless Config::R2_ENDPOINT

      Aws::S3::Client.new(
        access_key_id: Config::R2_ACCESS_KEY_ID,
        secret_access_key: Config::R2_SECRET_ACCESS_KEY,
        endpoint: Config::R2_ENDPOINT,
        region: "auto",
        force_path_style: true
      )
    end
  end
end
