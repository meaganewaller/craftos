# frozen_string_literal: true

source "https://rubygems.org"

# Load all CraftOS gems for development
gemspec path: "gems/fiber_units"
gemspec path: "gems/fiber_gauge"
gemspec path: "gems/fiber_pattern"
gemspec path: "gems/yarn_skein"

group :development do
  gem "rake"
  gem "irb"
end

group :test do
  gem "minitest"
  gem "minitest-reporters"
  gem "simplecov", require: false
  gem "simplecov-json", require: false
end

group :development, :lint do
  gem "standard", "~> 1.54.0"
  gem "standard-minitest"
end

group :development, :docs do
  gem "yard", require: false
  gem "rdoc"
  gem "kramdown"
  gem "webrick"
end
