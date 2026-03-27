# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class YamlExporterTest < Minitest::Test
  def setup
    @output_dir = Dir.mktmpdir("exporter_test")
    @exporter = Scraper::YamlExporter.new(output_dir: @output_dir)
  end

  def teardown
    FileUtils.rm_rf(@output_dir)
  end

  def test_exports_brand_yaml
    yarns = [{
      line: "Rios",
      slug: "rios",
      weight_category: "Worsted",
      yardage: 210,
      skein_weight: 100,
      fiber_content: {"wool" => 100},
      texture: "Plied",
      gauge: "4.5",
      needle_size: "US 7",
      style_categories: ["Solid", "Tonal"],
      image_url: "https://example.com/rios.jpg"
    }]

    path = @exporter.export_brand(brand_name: "Malabrigo", brand_slug: "malabrigo", yarns: yarns)
    assert File.exist?(path)

    data = YAML.safe_load_file(path)
    assert_equal "Malabrigo", data["brand"]
    assert_equal "malabrigo", data["slug"]
    assert_equal 1, data["yarns"].size
    assert_equal "Rios", data["yarns"][0]["line"]
    assert_equal 210, data["yarns"][0]["yardage"]
    assert_equal [], data["yarns"][0]["colorways"]
  end

  def test_exports_meta_yaml
    path = @exporter.export_meta(brands_count: 5, yarns_count: 42)
    assert File.exist?(path)

    data = YAML.safe_load_file(path)
    assert_equal 5, data["brands_count"]
    assert_equal 42, data["yarns_count"]
    assert data["scraped_at"]
    assert_equal "1.0", data["version"]
  end
end
