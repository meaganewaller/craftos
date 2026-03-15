# frozen_string_literal: true

require_relative "lib/fiber_gauge/version"

Gem::Specification.new do |spec|
  spec.name = "fiber_gauge"
  spec.version = FiberGauge::VERSION
  spec.authors = ["Meagan Waller"]
  spec.email = ["meagan@meaganwaller.com"]

  spec.summary = "A gem for measuring fiber usage in Ruby applications."
  spec.description = "FiberGauge is a Ruby gem that provides tools to measure and analyze fiber usage in Ruby applications."
  spec.homepage = "https://github.com/meaganewaller/fiber_gauge"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/meaganewaller/fiber_gauge"
  spec.metadata["changelog_uri"] = "https://github.com/meaganewaller/fiber_gauge/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "fiber_units", ">= 0.1"
  spec.add_development_dependency "minitest"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
