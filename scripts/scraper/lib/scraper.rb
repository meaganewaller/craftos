# frozen_string_literal: true

require_relative "scraper/config"
require_relative "scraper/http_client"
require_relative "scraper/yarn_sub/brand_list"
require_relative "scraper/yarn_sub/yarn_list"
require_relative "scraper/yarn_sub/yarn_detail"
require_relative "scraper/yaml_exporter"
require_relative "scraper/r2_uploader"
require_relative "scraper/colorways/base"

Dir.glob(File.join(__dir__, "scraper", "colorways", "*.rb")).each do |f|
  require f unless File.basename(f) == "base.rb"
end

module Scraper
end
