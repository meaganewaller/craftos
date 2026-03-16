#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "pathname"
require "rubygems"
require "shellwords"

class ReleaseReadiness
  ROOT = Pathname(__dir__).join("..").expand_path
  BRANCH_PATTERN = %r{\Arelease/(?<gem>[a-z0-9_]+)-v(?<version>[0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.-]+)?)\z}

  def initialize(branch:, base:, head:, github_output: nil, notes_version: nil, notes_gem: nil)
    @branch = branch
    @base = base
    @head = head
    @github_output = github_output
    @notes_version = notes_version
    @notes_gem = notes_gem
  end

  def run
    parsed = parse_branch!(@branch)
    gem_name = parsed[:gem]
    version = parsed[:version]
    gem_dir = ROOT.join("gems", gem_name)

    fail! "Release branch targets unknown gem `#{gem_name}`." unless gem_dir.directory?

    version_file = gem_dir.join("lib", gem_name, "version.rb")
    changelog_file = gem_dir.join("CHANGELOG.md")
    gemspec_file = gem_dir.join("#{gem_name}.gemspec")

    [version_file, changelog_file, gemspec_file].each do |path|
      fail! "Missing required release file: #{path.relative_path_from(ROOT)}" unless path.file?
    end

    changed_files = diff_files
    fail! "Release PR does not change any files." if changed_files.empty?

    changed_gems = changed_files.filter_map do |path|
      match = path.match(%r{\Agems/([^/]+)/})
      match[1] if match
    end.uniq.sort

    fail! "Release PR must change files under gems/#{gem_name}." unless changed_gems.include?(gem_name)

    extra_gems = changed_gems - [gem_name]
    unless extra_gems.empty?
      fail! "Release PR can only touch one gem. Also changed: #{extra_gems.join(", ")}"
    end

    unless changed_files.include?(version_file.relative_path_from(ROOT).to_s)
      fail! "Release PR must update #{version_file.relative_path_from(ROOT)}."
    end

    unless changed_files.include?(changelog_file.relative_path_from(ROOT).to_s)
      fail! "Release PR must update #{changelog_file.relative_path_from(ROOT)}."
    end

    current_version = extract_version(version_file)
    fail! "Branch version #{version} does not match #{version_file.relative_path_from(ROOT)} (#{current_version})." unless current_version == version

    changelog = changelog_file.read
    ensure_unreleased_empty!(changelog, changelog_file)
    ensure_release_heading!(changelog, changelog_file, version)
    ensure_version_progresses!(changelog, changelog_file, version)
    build_gem!(gem_dir)
    write_outputs(gem_name:, version:, gem_dir:, gemspec_file:)

    puts "Release readiness checks passed for #{gem_name} v#{version}."
  end

  def print_release_notes
    fail! "Provide --notes-gem and --notes-version together." unless @notes_gem && @notes_version

    changelog_file = ROOT.join("gems", @notes_gem, "CHANGELOG.md")
    fail! "Missing changelog for #{@notes_gem}: #{changelog_file.relative_path_from(ROOT)}" unless changelog_file.file?

    notes = extract_release_notes(changelog_file.read, @notes_version)
    fail! "Could not find changelog entry for version #{@notes_version} in #{changelog_file.relative_path_from(ROOT)}." if notes.nil?

    puts notes
  end

  private

  def parse_branch!(branch)
    match = branch.match(BRANCH_PATTERN)
    fail! "Release branches must look like release/<gem>-v<version>. Got `#{branch}`." unless match

    {gem: match[:gem], version: match[:version]}
  end

  def diff_files
    return [] unless @base && @head

    output = capture("git", "diff", "--name-only", "#{@base}...#{@head}")
    output.lines.map(&:strip).reject(&:empty?)
  end

  def extract_version(version_file)
    content = version_file.read
    match = content.match(/VERSION\s*=\s*"([^"]+)"/)
    fail! "Unable to find VERSION constant in #{version_file.relative_path_from(ROOT)}." unless match

    match[1]
  end

  def ensure_unreleased_empty!(changelog, changelog_file)
    match = changelog.match(/^##\s+\[?Unreleased\]?\s*$\n(?<body>.*?)(?=^##\s+|\z)/m)
    fail! "Expected an Unreleased section in #{changelog_file.relative_path_from(ROOT)}." unless match

    body = match[:body]
    remaining = body.lines.map(&:strip).reject(&:empty?)
    unless remaining.empty?
      fail! "#{changelog_file.relative_path_from(ROOT)} still has content under Unreleased. Move those notes into the new #{release_heading_label(@notes_version || extract_first_release_version(changelog) || "version")} section before merging."
    end
  end

  def ensure_release_heading!(changelog, changelog_file, version)
    versions = release_entries(changelog).map { |entry| entry[:version] }
    fail! "Expected a changelog entry for version #{version} in #{changelog_file.relative_path_from(ROOT)}." unless versions.include?(version)

    first_version = versions.first
    unless first_version == version
      fail! "Newest changelog entry in #{changelog_file.relative_path_from(ROOT)} must be #{version}; found #{first_version}."
    end
  end

  def ensure_version_progresses!(changelog, changelog_file, version)
    versions = release_entries(changelog).map { |entry| entry[:version] }
    previous_version = versions[1]
    return unless previous_version

    unless Gem::Version.new(version) > Gem::Version.new(previous_version)
      fail! "Release version #{version} must be greater than previous changelog version #{previous_version} in #{changelog_file.relative_path_from(ROOT)}."
    end
  end

  def extract_first_release_version(changelog)
    release_entries(changelog).first&.fetch(:version)
  end

  def build_gem!(gem_dir)
    Dir.chdir(gem_dir) do
      capture("gem", "build", "#{gem_dir.basename}.gemspec")
    end
  end

  def write_outputs(gem_name:, version:, gem_dir:, gemspec_file:)
    return unless @github_output

    File.open(@github_output, "a") do |file|
      file.puts "gem_name=#{gem_name}"
      file.puts "version=#{version}"
      file.puts "tag=#{gem_name}-v#{version}"
      file.puts "gem_dir=#{gem_dir.relative_path_from(ROOT)}"
      file.puts "gemspec=#{gemspec_file.relative_path_from(ROOT)}"
    end
  end

  def extract_release_notes(changelog, version)
    entry = release_entries(changelog).find { |item| item[:version] == version }
    return nil unless entry

    notes = entry[:body].strip
    notes.empty? ? "Release #{version}" : notes
  end

  def release_entries(changelog)
    entries = []
    current_version = nil
    current_body = []

    changelog.each_line do |line|
      if (match = line.match(/^##\s+\[?([0-9][^\]\s]*)\]?(?:\s+-\s+.*)?$/))
        entries << {version: current_version, body: current_body.join} if current_version
        current_version = match[1]
        current_body = []
      elsif current_version
        current_body << line
      end
    end

    entries << {version: current_version, body: current_body.join} if current_version
    entries
  end

  def capture(*command)
    output = `#{command.map { |part| Shellwords.escape(part) }.join(" ")} 2>&1`
    fail! output.strip unless $?.success?

    output
  end

  def release_heading_label(version)
    "[#{version}]"
  end

  def fail!(message)
    warn message
    exit 1
  end
end

options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: scripts/check_release_readiness.rb [options]"
  opts.on("--branch BRANCH", "Release branch name, for example release/fiber_units-v0.3.2") { |value| options[:branch] = value }
  opts.on("--base SHA", "Base commit SHA for the release PR diff") { |value| options[:base] = value }
  opts.on("--head SHA", "Head commit SHA for the release PR diff") { |value| options[:head] = value }
  opts.on("--github-output PATH", "Append extracted values for Actions job outputs") { |value| options[:github_output] = value }
  opts.on("--notes-gem GEM", "Print release notes for a gem from its changelog") { |value| options[:notes_gem] = value }
  opts.on("--notes-version VERSION", "Print release notes for a specific version") { |value| options[:notes_version] = value }
end

parser.parse!

checker = ReleaseReadiness.new(
  branch: options[:branch],
  base: options[:base],
  head: options[:head],
  github_output: options[:github_output],
  notes_version: options[:notes_version],
  notes_gem: options[:notes_gem]
)

if options[:notes_gem] || options[:notes_version]
  checker.print_release_notes
else
  if options[:branch].nil? || options[:base].nil? || options[:head].nil?
    warn parser
    exit 1
  end

  checker.run
end
