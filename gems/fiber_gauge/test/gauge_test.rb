# frozen_string_literal: true

require "test_helper"

class FiberGaugeGaugeTest < Minitest::Test
  def gauge
    FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 24.rows,
      width: 4.inches
    )
  end

  # -----------------------------
  # initialization
  # -----------------------------

  def test_initialization_stores_values
    g = gauge

    assert_equal 18, g.stitches.value
    assert_equal 24, g.rows.value
    assert_equal 4.inches, g.width
  end

  # -----------------------------
  # spi
  # -----------------------------

  def test_calculates_spi
    assert_equal 4.5, gauge.spi.round(2)
  end

  # -----------------------------
  # rpi
  # -----------------------------

  def test_calculates_rpi
    assert_equal 6, gauge.rpi
  end

  # -----------------------------
  # width_for_stitches
  # -----------------------------

  def test_calculates_width_for_stitches
    width = gauge.width_for_stitches(90.stitches)

    assert_equal 20.inches, width
  end

  # -----------------------------
  # required_stitches
  # -----------------------------

  def test_calculates_required_stitches_for_width
    stitches = gauge.required_stitches(20.inches)

    assert_equal 90.stitches, stitches
  end

  # -----------------------------
  # required_rows
  # -----------------------------

  def test_calculates_required_rows_for_height
    rows = gauge.required_rows(10.inches)

    assert_equal 60.rows, rows
  end

  def test_calculates_required_rows_for_metric_height
    rows = gauge.required_rows(25.4.centimeters)

    assert_equal 60.rows, rows
  end
end
