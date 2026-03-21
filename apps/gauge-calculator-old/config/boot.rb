ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

begin
  require "bootsnap/setup" # Speed up boot time by caching expensive operations.
rescue LoadError
  # Allow the app to boot in environments where bootsnap has not been installed.
end
