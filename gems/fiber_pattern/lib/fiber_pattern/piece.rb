# frozen_string_literal: true

module FiberPattern
  # A value object representing a single garment piece with stitch/row counts
  # and a gauge for deriving physical measurements.
  #
  # @example
  #   piece = FiberPattern::Piece.new(
  #     name: :front,
  #     cast_on: 90.stitches,
  #     bind_off: 70.stitches,
  #     rows: 120.rows,
  #     gauge: gauge
  #   )
  #   piece.bottom_width  # => FiberUnits::Length in inches
  #   piece.shape          # => :trapezoid
  class Piece
    # @return [Symbol] piece name (e.g. :front, :back, :sleeve)
    attr_reader :name

    # @return [FiberUnits::StitchCount] cast-on stitch count (bottom edge)
    attr_reader :cast_on

    # @return [FiberUnits::StitchCount] bind-off stitch count (top edge)
    attr_reader :bind_off

    # @return [FiberUnits::RowCount] total rows
    attr_reader :rows

    # @return [FiberGauge::Gauge] gauge for measurement conversion
    attr_reader :gauge

    # @return [FiberPattern::Shaping, nil] optional shaping schedule
    attr_reader :shaping

    # @param name [Symbol] piece identifier
    # @param cast_on [FiberUnits::StitchCount] cast-on stitch count
    # @param bind_off [FiberUnits::StitchCount] bind-off stitch count
    # @param rows [FiberUnits::RowCount] total row count
    # @param gauge [FiberGauge::Gauge] gauge for converting stitches/rows to measurements
    # @param shaping [FiberPattern::Shaping, nil] optional shaping data
    def initialize(name:, cast_on:, bind_off:, rows:, gauge:, shaping: nil)
      @name = name
      @cast_on = cast_on
      @bind_off = bind_off
      @rows = rows
      @gauge = gauge
      @shaping = shaping
    end

    # Physical width at the bottom (cast-on) edge.
    #
    # @return [FiberUnits::Length]
    def bottom_width
      gauge.width_for_stitches(cast_on)
    end

    # Physical width at the top (bind-off) edge.
    #
    # @return [FiberUnits::Length]
    def top_width
      gauge.width_for_stitches(bind_off)
    end

    # Physical height of the piece.
    #
    # @return [FiberUnits::Length]
    def height
      (rows.value.to_f / gauge.rpi).inches
    end

    # Whether this piece is a rectangle or trapezoid based on edge widths.
    #
    # @return [Symbol] :rectangle or :trapezoid
    def shape
      (cast_on.value == bind_off.value) ? :rectangle : :trapezoid
    end
  end
end
