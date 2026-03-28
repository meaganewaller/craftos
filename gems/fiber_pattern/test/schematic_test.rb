# frozen_string_literal: true

require "test_helper"

class FiberPatternSchematicTest < Minitest::Test
  def setup
    @gauge = FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 24.rows,
      width: 4.inches
    )
  end

  # -----------------------------
  # add_piece / pieces
  # -----------------------------

  def test_add_piece_stores_piece
    schematic = FiberPattern::Schematic.new
    schematic.add_piece(:front,
      cast_on: 90.stitches, bind_off: 70.stitches,
      rows: 120.rows, gauge: @gauge)

    assert_equal 1, schematic.pieces.size
    assert_instance_of FiberPattern::Piece, schematic.pieces[:front]
  end

  def test_add_piece_returns_piece
    schematic = FiberPattern::Schematic.new
    piece = schematic.add_piece(:back,
      cast_on: 90.stitches, bind_off: 90.stitches,
      rows: 120.rows, gauge: @gauge)

    assert_instance_of FiberPattern::Piece, piece
    assert_equal :back, piece.name
  end

  # -----------------------------
  # piece
  # -----------------------------

  def test_piece_fetches_by_name
    schematic = FiberPattern::Schematic.new
    schematic.add_piece(:front,
      cast_on: 90.stitches, bind_off: 70.stitches,
      rows: 120.rows, gauge: @gauge)

    piece = schematic.piece(:front)

    assert_equal :front, piece.name
  end

  def test_piece_raises_for_unknown_name
    schematic = FiberPattern::Schematic.new

    assert_raises(KeyError) { schematic.piece(:unknown) }
  end

  # -----------------------------
  # render
  # -----------------------------

  def test_render_returns_svg_string
    schematic = FiberPattern::Schematic.new
    schematic.add_piece(:front,
      cast_on: 90.stitches, bind_off: 70.stitches,
      rows: 120.rows, gauge: @gauge)

    svg = schematic.render(:svg)

    assert svg.start_with?("<svg")
    assert svg.end_with?("</svg>")
  end

  def test_render_defaults_to_svg
    schematic = FiberPattern::Schematic.new
    schematic.add_piece(:front,
      cast_on: 90.stitches, bind_off: 70.stitches,
      rows: 120.rows, gauge: @gauge)

    svg = schematic.render

    assert svg.include?("<svg")
  end

  def test_render_raises_for_unsupported_format
    schematic = FiberPattern::Schematic.new

    assert_raises(ArgumentError) { schematic.render(:pdf) }
  end

  def test_render_includes_all_pieces
    schematic = FiberPattern::Schematic.new
    schematic.add_piece(:front,
      cast_on: 90.stitches, bind_off: 70.stitches,
      rows: 120.rows, gauge: @gauge)
    schematic.add_piece(:back,
      cast_on: 90.stitches, bind_off: 90.stitches,
      rows: 120.rows, gauge: @gauge)

    svg = schematic.render(:svg)

    assert svg.include?('data-piece="front"')
    assert svg.include?('data-piece="back"')
  end
end
