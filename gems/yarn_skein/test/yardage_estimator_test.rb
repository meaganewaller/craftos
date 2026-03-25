# frozen_string_literal: true

require "test_helper"

class YarnSkeinYardageEstimatorTest < Minitest::Test
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

  def estimator
    YarnSkein::YardageEstimator.new(gauge: gauge, yarn: yarn)
  end

  # -----------------------------
  # yards_per_stitch
  # -----------------------------

  def test_yards_per_stitch_returns_positive_value
    assert estimator.yards_per_stitch > 0
  end

  def test_yards_per_stitch_uses_geometric_model
    spi = gauge.spi
    rpi = gauge.rpi
    expected = (1.0 / spi + 2.0 / rpi) / 36.0

    assert_in_delta expected, estimator.yards_per_stitch, 0.0001
  end

  # -----------------------------
  # for_piece
  # -----------------------------

  def test_for_piece_returns_yardage_and_skeins
    result = estimator.for_piece(stitches: 100.stitches, rows: 100.rows)

    assert result.key?(:yardage)
    assert result.key?(:skeins)
    assert_instance_of FiberUnits::Length, result[:yardage]
    assert_instance_of Integer, result[:skeins]
  end

  def test_for_piece_yardage_is_positive
    result = estimator.for_piece(stitches: 100.stitches, rows: 100.rows)

    assert result[:yardage].value > 0
  end

  def test_for_piece_includes_default_margin
    no_margin = estimator.for_piece(stitches: 100.stitches, rows: 100.rows, margin: 0.0)
    with_margin = estimator.for_piece(stitches: 100.stitches, rows: 100.rows)

    assert_in_delta(
      no_margin[:yardage].to(:yards).value * 1.10,
      with_margin[:yardage].to(:yards).value,
      0.01
    )
  end

  def test_for_piece_custom_margin
    no_margin = estimator.for_piece(stitches: 100.stitches, rows: 100.rows, margin: 0.0)
    with_margin = estimator.for_piece(stitches: 100.stitches, rows: 100.rows, margin: 0.20)

    assert_in_delta(
      no_margin[:yardage].to(:yards).value * 1.20,
      with_margin[:yardage].to(:yards).value,
      0.01
    )
  end

  def test_for_piece_zero_margin
    result = estimator.for_piece(stitches: 100.stitches, rows: 100.rows, margin: 0.0)

    total_ops = 100 * 100
    expected_yards = total_ops * estimator.yards_per_stitch

    assert_in_delta expected_yards, result[:yardage].to(:yards).value, 0.01
  end

  def test_for_piece_skeins_ceil_to_whole_number
    result = estimator.for_piece(stitches: 50.stitches, rows: 50.rows, margin: 0.0)

    raw_yards = 50 * 50 * estimator.yards_per_stitch
    expected_skeins = (raw_yards / 210.0).ceil

    assert_equal expected_skeins, result[:skeins]
  end

  # -----------------------------
  # for_rectangle
  # -----------------------------

  def test_for_rectangle_returns_yardage_and_skeins
    result = estimator.for_rectangle(width: 20.inches, height: 30.inches)

    assert result.key?(:yardage)
    assert result.key?(:skeins)
  end

  def test_for_rectangle_uses_gauge_to_compute_stitches
    rect_result = estimator.for_rectangle(width: 20.inches, height: 30.inches, margin: 0.0)

    stitches = gauge.required_stitches(20.inches)
    rows = gauge.required_rows(30.inches)
    piece_result = estimator.for_piece(stitches: stitches, rows: rows, margin: 0.0)

    assert_in_delta(
      piece_result[:yardage].to(:yards).value,
      rect_result[:yardage].to(:yards).value,
      0.01
    )
  end

  def test_for_rectangle_with_custom_margin
    no_margin = estimator.for_rectangle(width: 20.inches, height: 30.inches, margin: 0.0)
    with_margin = estimator.for_rectangle(width: 20.inches, height: 30.inches, margin: 0.15)

    assert_in_delta(
      no_margin[:yardage].to(:yards).value * 1.15,
      with_margin[:yardage].to(:yards).value,
      0.01
    )
  end

  # -----------------------------
  # realistic scenarios
  # -----------------------------

  def test_scarf_estimate_is_reasonable
    # A scarf ~8" wide, 60" long in worsted weight
    result = estimator.for_rectangle(width: 8.inches, height: 60.inches)

    yards = result[:yardage].to(:yards).value
    # A worsted scarf typically uses 200-400 yards
    assert yards > 100, "yardage #{yards} seems too low for a scarf"
    assert yards < 600, "yardage #{yards} seems too high for a scarf"
  end

  def test_blanket_estimate_is_reasonable
    # A throw blanket ~50" x 60" in worsted weight
    result = estimator.for_rectangle(width: 50.inches, height: 60.inches)

    yards = result[:yardage].to(:yards).value
    # A worsted throw typically uses 1500-3500 yards
    assert yards > 1000, "yardage #{yards} seems too low for a blanket"
    assert yards < 5000, "yardage #{yards} seems too high for a blanket"
  end

  def test_larger_piece_needs_more_yarn
    small = estimator.for_rectangle(width: 10.inches, height: 10.inches)
    large = estimator.for_rectangle(width: 20.inches, height: 20.inches)

    assert large[:yardage].to(:yards).value > small[:yardage].to(:yards).value
    assert large[:skeins] >= small[:skeins]
  end
end
