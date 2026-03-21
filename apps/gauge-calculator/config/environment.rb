ENV["SINATRA_ENV"] ||= "development"

require "bundler/setup"
Bundler.require(:default, ENV["SINATRA_ENV"])

app_root = File.expand_path("..", __dir__)

Dir[File.join(app_root, "app", "services", "*.rb")].sort.each { |file| require file }
require File.join(app_root, "app")
