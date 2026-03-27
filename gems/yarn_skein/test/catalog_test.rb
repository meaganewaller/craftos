# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "yaml"
require "fileutils"

class CatalogTest < Minitest::Test
  def setup
    @data_dir = Dir.mktmpdir("catalog_test")
    write_fixture("malabrigo.yml", {
      "brand" => "Malabrigo",
      "slug" => "malabrigo",
      "yarns" => [
        {
          "line" => "Rios",
          "slug" => "rios",
          "weight_category" => "worsted",
          "yardage" => 210,
          "skein_weight" => 100,
          "fiber_content" => {"wool" => 100},
          "colorways" => []
        },
        {
          "line" => "Mechita",
          "slug" => "mechita",
          "weight_category" => "fingering",
          "yardage" => 420,
          "skein_weight" => 100,
          "fiber_content" => {"wool" => 100},
          "colorways" => []
        }
      ]
    })

    write_fixture("cascade.yml", {
      "brand" => "Cascade",
      "slug" => "cascade",
      "yarns" => [
        {
          "line" => "220 Superwash",
          "slug" => "220-superwash",
          "weight_category" => "worsted",
          "yardage" => 200,
          "skein_weight" => 100,
          "fiber_content" => {"wool" => 100},
          "colorways" => []
        }
      ]
    })

    # Meta file should be ignored
    write_fixture("_meta.yml", {"scraped_at" => "2026-01-01", "version" => "1.0"})
  end

  def teardown
    FileUtils.rm_rf(@data_dir)
  end

  # ---- all ----

  def test_all_returns_yarn_objects
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)
    yarns = catalog.all

    assert_equal 3, yarns.size
    assert yarns.all? { |y| y.is_a?(YarnSkein::Yarn) }
  end

  def test_all_skips_meta_files
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)
    brands = catalog.all.map(&:brand).uniq

    refute_includes brands, "scraped_at"
  end

  # ---- filter ----

  def test_filter_by_brand
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)
    results = catalog.filter(brand: "Malabrigo")

    assert_equal 2, results.size
    assert results.all? { |y| y.brand == "Malabrigo" }
  end

  def test_filter_by_weight_category
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)
    results = catalog.filter(weight_category: :worsted)

    assert_equal 2, results.size
    assert results.all? { |y| y.weight_category == :worsted }
  end

  def test_filter_by_fiber
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)
    results = catalog.filter(fiber: :wool)

    assert_equal 3, results.size
  end

  def test_filter_combined
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)
    results = catalog.filter(brand: "Malabrigo", weight_category: :worsted)

    assert_equal 1, results.size
    assert_equal "Rios", results.first.line
  end

  # ---- brands ----

  def test_brands_returns_unique_sorted_list
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)

    assert_equal ["Cascade", "Malabrigo"], catalog.brands
  end

  # ---- find ----

  def test_find_returns_matching_yarn
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)
    yarn = catalog.find(brand: "Malabrigo", line: "Rios")

    assert_equal "Malabrigo", yarn.brand
    assert_equal "Rios", yarn.line
  end

  def test_find_is_case_insensitive
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)
    yarn = catalog.find(brand: "malabrigo", line: "rios")

    assert_equal "Malabrigo", yarn.brand
  end

  def test_find_returns_nil_when_not_found
    catalog = YarnSkein::Catalog.new(data_dir: @data_dir)

    assert_nil catalog.find(brand: "Unknown", line: "Yarn")
  end

  # ---- empty directory ----

  def test_empty_data_dir
    empty_dir = Dir.mktmpdir("empty_catalog")
    catalog = YarnSkein::Catalog.new(data_dir: empty_dir)

    assert_empty catalog.all
    assert_empty catalog.brands
  ensure
    FileUtils.rm_rf(empty_dir)
  end

  # ---- skips entries without yardage ----

  def test_skips_entries_missing_yardage
    dir = Dir.mktmpdir("incomplete_catalog")
    write_fixture_to(dir, "incomplete.yml", {
      "brand" => "Incomplete",
      "slug" => "incomplete",
      "yarns" => [
        {"line" => "NoYardage", "slug" => "no-yardage", "skein_weight" => 100, "fiber_content" => {}},
        {"line" => "Valid", "slug" => "valid", "yardage" => 200, "skein_weight" => 100, "fiber_content" => {"wool" => 100}}
      ]
    })

    catalog = YarnSkein::Catalog.new(data_dir: dir)
    assert_equal 1, catalog.all.size
    assert_equal "Valid", catalog.all.first.line
  ensure
    FileUtils.rm_rf(dir)
  end

  private

  def write_fixture(filename, data)
    write_fixture_to(@data_dir, filename, data)
  end

  def write_fixture_to(dir, filename, data)
    File.write(File.join(dir, filename), YAML.dump(data))
  end
end
