# frozen_string_literal: true

module Scraper
  module Config
    USER_AGENT = "CraftOS-Scraper/1.0 (+https://github.com/meaganewaller/craftos)"
    DELAY_SECONDS = ENV.fetch("SCRAPER_DELAY_SECONDS", 4).to_f
    CACHE_DIR = File.expand_path("../../tmp/cache", __dir__)

    BASE_URL = "https://yarnsub.com"

    TOP_TIER_BRANDS = %w[
      bernat berroco brooklyn_tweed brown_sheep caron cascade_yarns
      garnstudio debbie_bliss knit_picks lana_grossa lion_brand
      madelinetosh malabrigo_yarn noro patons_north_america
      plymouth_yarn red_heart rowan sirdar stylecraft valley_yarns
    ].freeze

    R2_ACCESS_KEY_ID = ENV["R2_ACCESS_KEY_ID"]
    R2_SECRET_ACCESS_KEY = ENV["R2_SECRET_ACCESS_KEY"]
    R2_BUCKET = ENV.fetch("R2_BUCKET", "craftos-yarn-images")
    R2_ACCOUNT_ID = ENV["R2_ACCOUNT_ID"]
    R2_ENDPOINT = R2_ACCOUNT_ID ? "https://#{R2_ACCOUNT_ID}.r2.cloudflarestorage.com" : nil
    R2_PUBLIC_URL = ENV.fetch("R2_PUBLIC_URL", R2_ACCOUNT_ID ? "https://pub-#{R2_ACCOUNT_ID}.r2.dev" : nil)
  end
end
