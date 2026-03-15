# Rakefile
# frozen_string_literal: true

require "rake"
require "bundler/setup"

def run_in(dir, cmd)
  puts "👉 #{dir}: #{cmd.join(" ")}"
  ok = Dir.chdir(dir) { system(*cmd) }
  abort "Command failed in #{dir}: #{cmd.join(" ")}" unless ok
end

def git_changed_files
  return [] unless system("git", "rev-parse", "--is-inside-work-tree", out: File::NULL, err: File::NULL)

  porcelain = `git status --porcelain`
  porcelain.lines.pluck(3..).compact.map(&:strip).reject(&:empty?)
end

def git_staged_files
  return [] unless system("git", "rev-parse", "--is-inside-work-tree", out: File::NULL, err: File::NULL)

  `git diff --name-only --cached`.lines.map(&:strip).reject(&:empty?)
end

def changed_components(paths)
  components = {root: false, gems: []}

  paths.each do |path|
    if path.start_with?("gems/")
      component = path.split("/")[1]
      components[:gems] << component if component
    else
      components[:root] = true
    end
  end

  components[:gems].uniq!
  components
end

namespace :craftos do
  desc "List all CraftOS gems"
  task :gems do
    Dir.children("gems").each { |g| puts g }
  end
end

namespace :bundle do
  desc "Run bundle install in host app and all gems"
  task :all do
    run_in(".", ["bundle", "install"])

    Dir.glob("gems/*").sort.each do |path|
      next unless File.exist?(File.join(path, "Gemfile"))
      run_in(path, ["bundle", "install"])
    end
  end
end

namespace :test do
  desc "Run tests across all gems"
  task :all do
    extra_args = ENV["ARGS"]&.split(" ") || []

    Dir.glob("gems/*").each do |gem_dir|
      test_path = File.join(gem_dir, "test")
      next unless File.directory?(test_path)

      puts "👉 Running specs for #{gem_dir}..."

      Dir.chdir(gem_dir) do
        system("bundle exec rake test", *extra_args) || abort("Tests failed for #{gem_dir}")
      end
    end

    Rake::Task["coverage:collate"].invoke
  end
end

namespace :lint do
  desc "Run StandardRB linter across all gems"
  task :all do
    extra_args = ENV["ARGS"]&.split(" ") || []
    run_in(".", ["bundle", "exec", "standardrb", *extra_args])

    Dir.glob("gems/*").sort.each do |path|
      next unless File.exist?(File.join(path, "Gemfile"))
      run_in(path, ["bundle", "exec", "standardrb", *extra_args])
    end
  end

  desc "Run StandardRB only in changed components (gems)"
  task :changed do
    paths = git_changed_files
    if paths.empty?
      puts "No git changes detected. Nothing to lint."
      next
    end

    components = changed_components(paths)
    extra_args = ENV["ARGS"]&.split(" ") || []

    run_in(".", ["bundle", "exec", "standardrb", *extra_args]) if components[:root]

    components[:gems].sort.each do |gem_name|
      path = File.join("gems", gem_name)
      next unless File.exist?(File.join(path, "Gemfile"))
      run_in(path, ["bundle", "exec", "standardrb", *extra_args])
    end
  end

  desc "Run StandardRB only in staged components (gems)"
  task :staged do
    paths = git_staged_files
    if paths.empty?
      puts "No staged changes detected. Nothing to lint."
      next
    end

    components = changed_components(paths)
    extra_args = ENV["ARGS"]&.split(" ") || []

    run_in(".", ["bundle", "exec", "standardrb", *extra_args]) if components[:root]

    components[:gems].sort.each do |gem_name|
      path = File.join("gems", gem_name)
      next unless File.exist?(File.join(path, "Gemfile"))
      run_in(path, ["bundle", "exec", "standardrb", *extra_args])
    end
  end

  task :fix do
    extra_args = ENV["ARGS"]&.split(" ") || []
    run_in(".", ["bundle", "exec", "standardrb", "--fix", *extra_args])

    Dir.glob("gems/*").sort.each do |path|
      next unless File.exist?(File.join(path, "Gemfile"))
      run_in(path, ["bundle", "exec", "standardrb", "--fix", *extra_args])
    end
  end

  task :fix_unsafe do
    extra_args = ENV["ARGS"]&.split(" ") || []
    run_in(".", ["bundle", "exec", "standardrb", "--fix-unsafely", *extra_args])

    Dir.glob("gems/*").sort.each do |path|
      next unless File.exist?(File.join(path, "Gemfile"))
      run_in(path, ["bundle", "exec", "standardrb", "--fix-unsafely", *extra_args])
    end
  end
end

namespace :docs do
  desc "Generate YARD docs"
  task :yard do
    system("bundle exec yard doc gems/**/*.rb")
  end
end

namespace :coverage do
  desc "Collate coverage from all gems into a single report"
  task :collate do
    require "simplecov"
    require "simplecov-json"

    resultsets = []
    resultsets.concat(Dir.glob("coverage/.resultset.json"))
    resultsets.concat(Dir.glob("gems/*/coverage/.resultset.json"))

    if resultsets.empty?
      puts "No coverage resultsets found. Run specs first."
      next
    end

    SimpleCov.collate(resultsets) do
      coverage_dir "coverage/combined"
      formatter SimpleCov::Formatter::MultiFormatter.new([
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::JSONFormatter
      ])
    end

    puts "✅ Combined coverage available at coverage/combined/index.html"
  end
end

desc "Run full CraftOS CI suite"
task ci: ["lint:standard", "test:all"]
