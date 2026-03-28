# frozen_string_literal: true

require "test_helper"

class YarnSkeinColorworkEstimatorTest < Minitest::Test
  def gauge
    FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 24.rows,
      width: 4.inches,
      height: 4.inches
    )
  end

  def yarn
    YarnSkein::Yarn.new(
      brand: "Malabrigo",
      line: "Rios",
      yardage: 210.yards,
      skein_weight: 100.grams
    )
  end

  def stranded_estimator
    YarnSkein::ColorworkEstimator.new(gauge: gauge, technique: :stranded)
  end

  def intarsia_estimator
    YarnSkein::ColorworkEstimator.new(gauge: gauge, technique: :intarsia)
  end

  # ----------------------------
  # initialization
  # ----------------------------

  def test_rejects_invalid_technique
    assert_raises(ArgumentError) do
      YarnSkein::ColorworkEstimator.new(gauge: gauge, technique: :mosaic)
    end
  end

  def test_accepts_stranded_technique
    est = YarnSkein::ColorworkEstimator.new(gauge: gauge, technique: :stranded)
    assert_equal :stranded, est.technique
  end

  def test_accepts_intarsia_technique
    est = YarnSkein::ColorworkEstimator.new(gauge: gauge, technique: :intarsia)
    assert_equal :intarsia, est.technique
  end

  # ----------------------------
  # color validation
  # ----------------------------

  def test_rejects_empty_colors
    assert_raises(ArgumentError) do
      stranded_estimator.estimate(width: 20.inches, height: 20.inches, colors: {})
    end
  end

  def test_rejects_non_hash_colors
    assert_raises(ArgumentError) do
      stranded_estimator.estimate(width: 20.inches, height: 20.inches, colors: [0.5, 0.5])
    end
  end

  def test_rejects_proportions_not_summing_to_one
    assert_raises(ArgumentError) do
      stranded_estimator.estimate(
        width: 20.inches, height: 20.inches,
        colors: {main: 0.60, contrast: 0.30}
      )
    end
  end

  def test_rejects_zero_proportion
    assert_raises(ArgumentError) do
      stranded_estimator.estimate(
        width: 20.inches, height: 20.inches,
        colors: {main: 1.0, contrast: 0.0}
      )
    end
  end

  # ----------------------------
  # stranded estimation
  # ----------------------------

  def test_stranded_returns_per_color_yardage
    result = stranded_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.60, contrast: 0.40}
    )

    assert result.key?(:main)
    assert result.key?(:contrast)
    assert result.key?(:total)
    assert_instance_of FiberUnits::Length, result[:main][:yardage]
    assert_instance_of FiberUnits::Length, result[:contrast][:yardage]
    assert_instance_of FiberUnits::Length, result[:total][:yardage]
  end

  def test_stranded_includes_float_overhead
    stranded = stranded_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.60, contrast: 0.40},
      margin: 0.0, float_overhead: 0.20
    )

    intarsia = intarsia_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.60, contrast: 0.40},
      margin: 0.0
    )

    # Stranded total should be 20% more than intarsia (due to float overhead)
    stranded_total = stranded[:total][:yardage].to(:yards).value
    intarsia_total = intarsia[:total][:yardage].to(:yards).value

    assert_in_delta intarsia_total * 1.20, stranded_total, 0.01
  end

  def test_stranded_custom_float_overhead
    low_overhead = stranded_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.60, contrast: 0.40},
      margin: 0.0, float_overhead: 0.15
    )

    high_overhead = stranded_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.60, contrast: 0.40},
      margin: 0.0, float_overhead: 0.25
    )

    assert high_overhead[:total][:yardage].to(:yards).value >
           low_overhead[:total][:yardage].to(:yards).value
  end

  def test_stranded_proportions_affect_distribution
    result = stranded_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.70, contrast: 0.30},
      margin: 0.0
    )

    main_yards = result[:main][:yardage].to(:yards).value
    contrast_yards = result[:contrast][:yardage].to(:yards).value

    assert_in_delta 7.0 / 3.0, main_yards / contrast_yards, 0.01
  end

  # ----------------------------
  # intarsia estimation
  # ----------------------------

  def test_intarsia_no_float_overhead
    intarsia = intarsia_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {left: 0.50, right: 0.50},
      margin: 0.0
    )

    # For intarsia, each half should get half the base yardage
    left_yards = intarsia[:left][:yardage].to(:yards).value
    right_yards = intarsia[:right][:yardage].to(:yards).value

    assert_in_delta left_yards, right_yards, 0.01
  end

  def test_intarsia_total_matches_base_yardage
    intarsia = intarsia_estimator.estimate(
      width: 20.inches, height: 30.inches,
      colors: {left: 0.50, right: 0.50},
      margin: 0.0
    )

    # Total intarsia yardage should match a plain YardageEstimator (no margin)
    base = YarnSkein::YardageEstimator.new(gauge: gauge, yarn: yarn)
    base_result = base.for_rectangle(width: 20.inches, height: 30.inches, margin: 0.0)

    assert_in_delta(
      base_result[:yardage].to(:yards).value,
      intarsia[:total][:yardage].to(:yards).value,
      0.01
    )
  end

  # ----------------------------
  # skein calculations
  # ----------------------------

  def test_includes_skeins_when_yarn_provided
    result = stranded_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.60, contrast: 0.40},
      yarn: yarn
    )

    assert result[:main].key?(:skeins)
    assert result[:contrast].key?(:skeins)
    assert_instance_of Integer, result[:main][:skeins]
    assert_instance_of Integer, result[:contrast][:skeins]
  end

  def test_omits_skeins_when_no_yarn
    result = stranded_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.60, contrast: 0.40}
    )

    refute result[:main].key?(:skeins)
    refute result[:contrast].key?(:skeins)
  end

  # ----------------------------
  # margin
  # ----------------------------

  def test_default_margin_applied
    no_margin = intarsia_estimator.estimate(
      width: 20.inches, height: 20.inches,
      colors: {main: 1.0},
      margin: 0.0
    )

    with_margin = intarsia_estimator.estimate(
      width: 20.inches, height: 20.inches,
      colors: {main: 1.0}
    )

    assert_in_delta(
      no_margin[:main][:yardage].to(:yards).value * 1.10,
      with_margin[:main][:yardage].to(:yards).value,
      0.01
    )
  end

  # ----------------------------
  # multi-color
  # ----------------------------

  def test_three_color_stranded
    result = stranded_estimator.estimate(
      width: 40.inches, height: 24.inches,
      colors: {main: 0.50, contrast_a: 0.30, contrast_b: 0.20},
      margin: 0.0
    )

    assert result.key?(:main)
    assert result.key?(:contrast_a)
    assert result.key?(:contrast_b)
    assert result.key?(:total)

    total = result[:main][:yardage].to(:yards).value +
            result[:contrast_a][:yardage].to(:yards).value +
            result[:contrast_b][:yardage].to(:yards).value

    assert_in_delta total, result[:total][:yardage].to(:yards).value, 0.01
  end

  # ----------------------------
  # realistic scenario
  # ----------------------------

  def test_fair_isle_yoke_estimate_is_reasonable
    # A Fair Isle yoke ~20" wide, 12" tall in worsted weight
    result = stranded_estimator.estimate(
      width: 20.inches, height: 12.inches,
      colors: {main: 0.60, contrast: 0.40},
      yarn: yarn
    )

    main_yards = result[:main][:yardage].to(:yards).value
    contrast_yards = result[:contrast][:yardage].to(:yards).value
    total_yards = result[:total][:yardage].to(:yards).value

    assert total_yards > 50, "total #{total_yards} seems too low"
    assert total_yards < 500, "total #{total_yards} seems too high"
    assert main_yards > contrast_yards, "main color should use more yarn"
  end
end
