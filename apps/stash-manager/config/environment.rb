ENV["SINATRA_ENV"] ||= "development"

require "bundler/setup"
Bundler.require(:default, ENV["SINATRA_ENV"])

app_root = File.expand_path("..", __dir__)

db_path = ENV.fetch("DATABASE_URL") {
  env = ENV["SINATRA_ENV"]
  "sqlite://#{File.join(app_root, "db", "stash_#{env}.sqlite3")}"
}

DB = Sequel.connect(db_path)
Sequel.extension :migration
Sequel::Migrator.run(DB, File.join(app_root, "db", "migrations"))

Dir[File.join(app_root, "app", "models", "*.rb")].sort.each { |file| require file }
Dir[File.join(app_root, "app", "services", "*.rb")].sort.each { |file| require file }
require File.join(app_root, "app")
