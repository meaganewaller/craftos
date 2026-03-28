# frozen_string_literal: true

require "test_helper"

class FiberPatternPieceTest < Minitest::Test
  # Gauge: 18 stitches / 24 rows per 4 inches
  # spi = 4.5, rpi = 6.0

  def setup
    @gauge = FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 24.rows,
      width: 4.inches
    )
  end

  # -----------------------------
  # bottom_width
  # -----------------------------

  def test_bottom_width_from_gauge
    piece = build_piece(cast_on: 90.stitches, bind_off: 70.stitches)

    # 90 stitches / 4.5 spi = 20.0 inches
    assert_in_delta 20.0, piece.bottom_width.to(:inches).value, 0.01
  end

  # -----------------------------
  # top_width
  # -----------------------------

  def test_top_width_from_gauge
    piece = build_piece(cast_on: 90.stitches, bind_off: 70.stitches)

    # 70 stitches / 4.5 spi ≈ 15.56 inches
    assert_in_delta 15.56, piece.top_width.to(:inches).value, 0.01
  end

  # -----------------------------
  # height
  # -----------------------------

  def test_height_from_gauge
    piece = build_piece(cast_on: 90.stitches, bind_off: 70.stitches, rows: 120.rows)

    # 120 rows / 6.0 rpi = 20.0 inches
    assert_in_delta 20.0, piece.height.to(:inches).value, 0.01
  end

  # -----------------------------
  # shape
  # -----------------------------

  def test_shape_is_rectangle_when_equal_widths
    piece = build_piece(cast_on: 90.stitches, bind_off: 90.stitches)

    assert_equal :rectangle, piece.shape
  end

  def test_shape_is_trapezoid_when_different_widths
    piece = build_piece(cast_on: 90.stitches, bind_off: 70.stitches)

    assert_equal :trapezoid, piece.shape
  end

  # -----------------------------
  # shaping
  # -----------------------------

  def test_shaping_defaults_to_nil
    piece = build_piece(cast_on: 90.stitches, bind_off: 90.stitches)

    assert_nil piece.shaping
  end

  def test_accepts_shaping_object
    shaping = FiberPattern::Shaping.new(
      from: 90.stitches,
      to: 70.stitches,
      over: 120.rows,
      method: :decrease
    )
    piece = build_piece(cast_on: 90.stitches, bind_off: 70.stitches, shaping: shaping)

    assert_equal shaping, piece.shaping
  end

  private

  def build_piece(cast_on: 90.stitches, bind_off: 70.stitches, rows: 120.rows, shaping: nil)
    FiberPattern::Piece.new(
      name: :front,
      cast_on: cast_on,
      bind_off: bind_off,
      rows: rows,
      gauge: @gauge,
      shaping: shaping
    )
  end
end
