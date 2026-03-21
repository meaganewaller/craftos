# frozen_string_literal: true

require "test_helper"

class YarnSkeinSubstitutionTest < Minitest::Test
  def build_yarn(line:, yardage:, skein_weight:, fiber_content: nil)
    YarnSkein::Yarn.new(
      brand: "TestBrand",
      line: line,
      yardage: yardage,
      skein_weight: skein_weight,
      fiber_content: fiber_content
    )
  end

  def target_yarn
    @target_yarn ||= build_yarn(line: "Target", yardage: 210.yards, skein_weight: 100.grams)
  end

  # 210 yards/100g => worsted, yards_per_100g = 210

  def close_match
    @close_match ||= build_yarn(line: "Close", yardage: 200.yards, skein_weight: 100.grams)
  end

  def exact_match
    @exact_match ||= build_yarn(line: "Exact", yardage: 210.yards, skein_weight: 100.grams)
  end

  def too_far
    @too_far ||= build_yarn(line: "TooFar", yardage: 300.yards, skein_weight: 100.grams)
  end

  def different_category
    @different_category ||= build_yarn(line: "Bulky", yardage: 120.yards, skein_weight: 100.grams)
  end

  def wool_yarn
    @wool_yarn ||= build_yarn(
      line: "Wool",
      yardage: 200.yards,
      skein_weight: 100.grams,
      fiber_content: YarnSkein::FiberBlend.new(wool: 100)
    )
  end

  def cotton_yarn
    @cotton_yarn ||= build_yarn(
      line: "Cotton",
      yardage: 200.yards,
      skein_weight: 100.grams,
      fiber_content: YarnSkein::FiberBlend.new(cotton: 100)
    )
  end

  # -----------------------------
  # matches
  # -----------------------------

  def test_returns_yarns_matching_weight_category_and_grist
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [close_match, too_far])

    assert_equal [close_match], sub.matches
  end

  def test_excludes_target_yarn_from_results
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [target_yarn, close_match])

    assert_equal [close_match], sub.matches
  end

  def test_excludes_different_weight_category
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [different_category])

    assert_empty sub.matches
  end

  def test_returns_empty_for_empty_catalog
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [])

    assert_empty sub.matches
  end

  def test_returns_empty_when_no_matches
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [too_far, different_category])

    assert_empty sub.matches
  end

  # -----------------------------
  # tolerance
  # -----------------------------

  def test_configurable_tolerance
    # close_match is 200/210 = ~0.952, within 15% but outside 2%
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [close_match])

    assert_equal [close_match], sub.matches(tolerance: 0.15)
    assert_empty sub.matches(tolerance: 0.02)
  end

  # -----------------------------
  # fiber filter
  # -----------------------------

  def test_filters_by_fiber_content
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [wool_yarn, cotton_yarn])

    assert_equal [wool_yarn], sub.matches(fiber: :wool)
  end

  def test_fiber_filter_excludes_yarns_without_fiber_content
    yarn_no_fiber = build_yarn(line: "NoFiber", yardage: 200.yards, skein_weight: 100.grams)
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [yarn_no_fiber, wool_yarn])

    assert_equal [wool_yarn], sub.matches(fiber: :wool)
  end

  def test_includes_exact_grist_match
    sub = YarnSkein::Substitution.new(target: target_yarn, catalog: [exact_match])

    assert_equal [exact_match], sub.matches
  end
end
