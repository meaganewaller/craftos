# frozen_string_literal: true

require "test_helper"

class FiberPatternScalingTest < Minitest::Test
  # -----------------------------
  # scale_stitches
  # -----------------------------

  def test_scale_stitches_between_gauges
    pattern_gauge = FiberGauge::Gauge.new(
      stitches: 20.stitches,
      rows: 28.rows,
      width: 4.inches
    )

    knitter_gauge = FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 26.rows,
      width: 4.inches
    )

    result = FiberPattern::Scaling.scale_stitches(
      100.stitches,
      pattern_gauge,
      knitter_gauge
    )

    assert_equal 90.stitches, result
  end

  # -----------------------------
  # scale_rows
  # -----------------------------

  def test_scale_rows_between_gauges
    pattern_gauge = FiberGauge::Gauge.new(
      stitches: 20.stitches,
      rows: 28.rows,
      width: 4.inches
    )

    knitter_gauge = FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 24.rows,
      width: 4.inches
    )

    result = FiberPattern::Scaling.scale_rows(
      56.rows,
      pattern_gauge,
      knitter_gauge
    )

    assert_equal 48.rows, result
  end
end
