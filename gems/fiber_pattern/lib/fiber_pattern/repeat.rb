# frozen_string_literal: true

module FiberPattern
  # Adjusts stitch counts to satisfy a repeat multiple and optional offset.
  class Repeat
    # @return [FiberUnits::Stitches] repeat multiple used for rounding
    # @return [FiberUnits::Stitches] fixed offset applied before rounding
    attr_reader :multiple, :offset

    # @param multiple [FiberUnits::Stitches] repeat size required by the pattern
    # @param offset [FiberUnits::Stitches] offset preserved when aligning to the repeat
    def initialize(multiple:, offset: 0.stitches)
      @multiple = multiple
      @offset = offset
    end

    # Rounds a stitch count up to the next valid repeat-compatible value.
    #
    # @param stitches [FiberUnits::Stitches] stitch count to adjust
    # @return [FiberUnits::Stitches] smallest valid count meeting the repeat constraints
    def adjust(stitches)
      m = multiple.value
      o = offset.value

      adjusted =
        ((stitches.value - o).to_f / m).ceil * m + o

      adjusted.stitches
    end
  end
end
