# frozen_string_literal: true

require "test_helper"

class YarnSkeinYarnTest < Minitest::Test
  def build_yarn(**attrs)
    YarnSkein::Yarn.new(
      brand: "Malabrigo",
      line: "Rios",
      yardage: 210.yards,
      skein_weight: 100.grams,
      **attrs
    )
  end

  # -----------------------------
  # Initialization
  # -----------------------------

  def test_initialization_stores_attributes
    yarn = build_yarn

    assert_equal "Malabrigo", yarn.brand
    assert_equal "Rios", yarn.line
    assert_equal 210.yards, yarn.yardage
    assert_equal 100.grams, yarn.skein_weight
  end

  # -----------------------------
  # Grist
  # -----------------------------

  def test_grist_returns_ratio
    yarn = build_yarn

    assert_instance_of FiberUnits::Ratio, yarn.grist
  end

  # -----------------------------
  # Weight category
  # -----------------------------

  def test_weight_category_worsted
    yarn = build_yarn

    assert_equal :worsted, yarn.weight_category
  end

  def test_weight_category_fingering
    yarn = build_yarn(
      line: "Sock",
      yardage: 400.yards
    )

    assert_equal :fingering, yarn.weight_category
  end

  def test_weight_category_bulky
    yarn = build_yarn(
      line: "Chunky",
      yardage: 100.yards
    )

    assert_equal :bulky, yarn.weight_category
  end

  # -----------------------------
  # Validation
  # -----------------------------

  def test_requires_yardage_to_be_length
    error = assert_raises(ArgumentError) do
      YarnSkein::Yarn.new(
        brand: "Malabrigo",
        line: "Rios",
        yardage: 210,
        skein_weight: 100.grams
      )
    end

    assert_match(/yardage/i, error.message)
  end

  def test_requires_skein_weight_to_be_weight
    error = assert_raises(ArgumentError) do
      YarnSkein::Yarn.new(
        brand: "Malabrigo",
        line: "Rios",
        yardage: 210.yards,
        skein_weight: 100
      )
    end

    assert_match(/skein_weight/i, error.message)
  end

  # -----------------------------
  # yards_per_100g
  # -----------------------------

  def test_calculates_yards_per_100g
    yarn = build_yarn

    assert_equal 210, yarn.yards_per_100g
  end

  # -----------------------------
  # similar_weight_to?
  # -----------------------------

  def test_similar_weight_for_same_category
    rios = build_yarn

    cascade = YarnSkein::Yarn.new(
      brand: "Cascade",
      line: "220",
      yardage: 220.yards,
      skein_weight: 100.grams
    )

    assert rios.similar_weight_to?(cascade)
  end

  def test_not_similar_for_different_categories
    rios = build_yarn

    sock = YarnSkein::Yarn.new(
      brand: "Malabrigo",
      line: "Sock",
      yardage: 440.yards,
      skein_weight: 100.grams
    )

    refute rios.similar_weight_to?(sock)
  end

  def test_not_similar_for_very_different_yarns
    rios = build_yarn

    lace = YarnSkein::Yarn.new(
      brand: "Malabrigo",
      line: "Lace",
      yardage: 800.yards,
      skein_weight: 100.grams
    )

    refute rios.similar_weight_to?(lace)
  end

  # -----------------------------
  # skeins_required
  # -----------------------------

  def test_skeins_required_exact
    yarn = build_yarn

    assert_equal 2, yarn.skeins_required(420.yards)
  end

  def test_skeins_required_rounds_up
    yarn = build_yarn

    assert_equal 2, yarn.skeins_required(300.yards)
  end

  def test_skeins_required_handles_unit_conversion
    yarn = build_yarn

    assert_equal 2, yarn.skeins_required(384.meters)
  end

  def test_skeins_required_requires_length
    yarn = build_yarn

    assert_raises(ArgumentError) do
      yarn.skeins_required(300)
    end
  end

  # -----------------------------
  # total_yardage
  # -----------------------------

  def test_total_yardage_returns_length
    yarn = build_yarn

    result = yarn.total_yardage(2)

    assert_instance_of FiberUnits::Length, result
  end

  def test_total_yardage_calculates_correct_value
    yarn = build_yarn

    assert_equal 630.yards, yarn.total_yardage(3)
  end

  def test_total_yardage_requires_positive_count
    yarn = build_yarn

    assert_raises(ArgumentError) do
      yarn.total_yardage(0)
    end
  end

  # -----------------------------
  # Equality
  # -----------------------------

  def test_equal_yarns
    yarn1 = build_yarn
    yarn2 = build_yarn

    assert_equal yarn1, yarn2
  end

  def test_different_yarns_not_equal
    yarn1 = build_yarn

    yarn2 = YarnSkein::Yarn.new(
      brand: "Malabrigo",
      line: "Sock",
      yardage: 400.yards,
      skein_weight: 100.grams
    )

    refute_equal yarn1, yarn2
  end
end
