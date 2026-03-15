# frozen_string_literal: true

require "test_helper"

class FiberPatternSizingTest < Minitest::Test
  def gauge
    FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 24.rows,
      width: 4.inches
    )
  end

  # -----------------------------
  # cast_on_for
  # -----------------------------

  def test_cast_on_for_calculates_stitches_for_width
    sizing = FiberPattern::Sizing.new(gauge: gauge)

    stitches = sizing.cast_on_for(20.inches)

    assert_equal 90.stitches, stitches
  end

  # -----------------------------
  # stitch repeat
  # -----------------------------

  def test_cast_on_rounds_up_to_repeat_multiple
    sizing = FiberPattern::Sizing.new(
      gauge: gauge,
      repeat: FiberPattern::Repeat.new(multiple: 8.stitches)
    )

    stitches = sizing.cast_on_for(38.inches)

    assert_equal 176.stitches, stitches
  end

  # -----------------------------
  # repeat offset
  # -----------------------------

  def test_cast_on_adjusts_for_repeat_offset
    sizing = FiberPattern::Sizing.new(
      gauge: gauge,
      repeat: FiberPattern::Repeat.new(
        multiple: 8.stitches,
        offset: 2.stitches
      )
    )

    stitches = sizing.cast_on_for(38.inches)

    assert_equal 178.stitches, stitches
  end

  # -----------------------------
  # width_for
  # -----------------------------

  def test_width_for_calculates_width_from_stitches
    sizing = FiberPattern::Sizing.new(gauge: gauge)

    width = sizing.width_for(90.stitches)

    assert_equal 20.inches, width
  end

  def test_width_for_with_repeat_adjusted_stitches
    sizing = FiberPattern::Sizing.new(
      gauge: gauge,
      repeat: FiberPattern::Repeat.new(multiple: 8.stitches)
    )

    width = sizing.width_for(176.stitches)

    assert_equal 39.11, width.value.round(2)
    assert_equal :inches, width.unit
  end
end
