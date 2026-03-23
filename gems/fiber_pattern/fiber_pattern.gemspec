# frozen_string_literal: true

lib_name = "fiber_pattern"

require_relative "lib/fiber_pattern/version"
monorepo_url = "https://github.com/meaganewaller/craftos"
repository_url = "#{monorepo_url}/tree/main/gems/#{lib_name}"

Gem::Specification.new do |spec|
  spec.summary = "Pattern sizing and stitch math for knitting and crochet."
  spec.description = "A Ruby gem for calculating pattern sizes and stitch counts for knitting and crochet projects."
  spec.homepage = repository_url
  spec.licenses = ["MIT"]
  spec.name = lib_name
  spec.version = FiberPattern::VERSION

  spec.metadata = {
    "source_code_uri" => repository_url,
    "bug_tracker_uri" => "#{monorepo_url}/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.add_dependency "fiber_units", "~> 0.3.1"
  spec.add_dependency "fiber_gauge"

  spec.required_ruby_version = ">= 3.4"

  spec.authors = ["Meagan Waller"]
  spec.email = ["meagan@meaganwaller.com"]
  might_be_parsing_by_tool_as_dependabot = `git ls-files`.lines.empty?
  files = Dir["README*", "*LICENSE*", "lib/**/*", "sig/**/*"].uniq
  if !might_be_parsing_by_tool_as_dependabot && files.grep(%r{\A(?:lib|sig)/}).size < 4
    raise "obvious mistaken in packaging files: #{files.inspect}"
  end
  spec.files = files
  spec.require_paths = ["lib"]
end
