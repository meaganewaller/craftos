# frozen_string_literal: true

module FiberPattern
  # Composes named garment pieces and renders them as a schematic.
  #
  # @example
  #   schematic = FiberPattern::Schematic.new
  #   schematic.add_piece(:front,
  #     cast_on: 90.stitches, bind_off: 70.stitches,
  #     rows: 120.rows, gauge: gauge
  #   )
  #   schematic.render(:svg)  # => SVG string
  class Schematic
    # @return [Hash{Symbol => FiberPattern::Piece}] named pieces
    attr_reader :pieces

    def initialize
      @pieces = {}
    end

    # Adds a piece to the schematic.
    #
    # @param name [Symbol] piece identifier (e.g. :front, :back, :sleeve)
    # @param cast_on [FiberUnits::StitchCount] cast-on stitch count
    # @param bind_off [FiberUnits::StitchCount] bind-off stitch count
    # @param rows [FiberUnits::RowCount] total row count
    # @param gauge [FiberGauge::Gauge] gauge for measurement conversion
    # @param shaping [FiberPattern::Shaping, nil] optional shaping data
    # @return [FiberPattern::Piece]
    def add_piece(name, cast_on:, bind_off:, rows:, gauge:, shaping: nil)
      @pieces[name] = Piece.new(
        name: name,
        cast_on: cast_on,
        bind_off: bind_off,
        rows: rows,
        gauge: gauge,
        shaping: shaping
      )
    end

    # Fetches a piece by name.
    #
    # @param name [Symbol] piece identifier
    # @return [FiberPattern::Piece]
    # @raise [KeyError] if the piece is not found
    def piece(name)
      @pieces.fetch(name)
    end

    # Renders the schematic in the given format.
    #
    # @param format [Symbol] output format (:svg)
    # @return [String] rendered output
    def render(format = :svg)
      case format
      when :svg
        SvgRenderer.new(self).render
      else
        raise ArgumentError, "unsupported format: #{format.inspect}"
      end
    end
  end
end
