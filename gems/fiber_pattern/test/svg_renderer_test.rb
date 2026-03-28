# frozen_string_literal: true

require "test_helper"

class FiberPatternSvgRendererTest < Minitest::Test
  def setup
    @gauge = FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 24.rows,
      width: 4.inches
    )
  end

  # -----------------------------
  # SVG structure
  # -----------------------------

  def test_renders_valid_svg_wrapper
    svg = render_single_piece

    assert svg.start_with?("<svg")
    assert svg.end_with?("</svg>")
    assert svg.include?("xmlns=")
    assert svg.include?("viewBox=")
  end

  def test_empty_schematic_renders_empty_svg
    schematic = FiberPattern::Schematic.new
    svg = FiberPattern::SvgRenderer.new(schematic).render

    assert svg.include?("<svg")
    assert svg.include?("</svg>")
  end

  # -----------------------------
  # shape rendering
  # -----------------------------

  def test_rectangle_piece_renders_rect_element
    svg = render_piece(cast_on: 90.stitches, bind_off: 90.stitches)

    assert svg.include?("<rect")
  end

  def test_trapezoid_piece_renders_polygon_element
    svg = render_piece(cast_on: 90.stitches, bind_off: 70.stitches)

    assert svg.include?("<polygon")
  end

  # -----------------------------
  # labels and dimensions
  # -----------------------------

  def test_piece_name_label_present
    svg = render_single_piece

    assert svg.include?(">front<")
  end

  def test_dimension_labels_show_measurements
    # 90 stitches at 4.5 spi = 20.0 inches
    svg = render_piece(cast_on: 90.stitches, bind_off: 90.stitches, rows: 120.rows)

    assert svg.include?("20.0&quot;")
  end

  def test_trapezoid_shows_both_width_dimensions
    svg = render_piece(cast_on: 90.stitches, bind_off: 70.stitches, rows: 120.rows)

    # Bottom: 90/4.5 = 20.0"
    assert svg.include?("20.0&quot;")
    # Top: 70/4.5 ≈ 15.6"
    assert svg.include?("15.6&quot;")
  end

  # -----------------------------
  # shaping markers
  # -----------------------------

  def test_shaping_markers_rendered_when_shaping_present
    shaping = FiberPattern::Shaping.new(
      from: 90.stitches, to: 70.stitches,
      over: 120.rows, method: :decrease
    )

    svg = render_piece(
      cast_on: 90.stitches, bind_off: 70.stitches,
      rows: 120.rows, shaping: shaping
    )

    assert svg.include?("<circle")
  end

  def test_no_shaping_markers_when_shaping_nil
    svg = render_piece(cast_on: 90.stitches, bind_off: 70.stitches, rows: 120.rows)

    refute svg.include?("<circle")
  end

  # -----------------------------
  # multi-piece layout
  # -----------------------------

  def test_multi_piece_layout_has_two_groups
    schematic = FiberPattern::Schematic.new
    schematic.add_piece(:front,
      cast_on: 90.stitches, bind_off: 70.stitches,
      rows: 120.rows, gauge: @gauge)
    schematic.add_piece(:sleeve,
      cast_on: 60.stitches, bind_off: 40.stitches,
      rows: 80.rows, gauge: @gauge)

    svg = FiberPattern::SvgRenderer.new(schematic).render

    assert svg.include?('data-piece="front"')
    assert svg.include?('data-piece="sleeve"')
  end

  # -----------------------------
  # scale
  # -----------------------------

  def test_custom_scale_changes_dimensions
    schematic = build_schematic(cast_on: 90.stitches, bind_off: 90.stitches, rows: 120.rows)

    svg_default = FiberPattern::SvgRenderer.new(schematic, scale: 10).render
    svg_large = FiberPattern::SvgRenderer.new(schematic, scale: 20).render

    # Extract viewBox width — larger scale should produce a larger SVG
    default_width = extract_viewbox_width(svg_default)
    large_width = extract_viewbox_width(svg_large)

    assert large_width > default_width
  end

  private

  def render_single_piece
    render_piece(cast_on: 90.stitches, bind_off: 70.stitches, rows: 120.rows)
  end

  def render_piece(cast_on:, bind_off:, rows: 120.rows, shaping: nil)
    schematic = build_schematic(cast_on: cast_on, bind_off: bind_off, rows: rows, shaping: shaping)
    FiberPattern::SvgRenderer.new(schematic).render
  end

  def build_schematic(cast_on:, bind_off:, rows:, shaping: nil)
    schematic = FiberPattern::Schematic.new
    schematic.add_piece(:front,
      cast_on: cast_on, bind_off: bind_off,
      rows: rows, gauge: @gauge, shaping: shaping)
    schematic
  end

  def extract_viewbox_width(svg)
    match = svg.match(/viewBox="0 0 (\d+)/)
    match[1].to_i
  end
end
