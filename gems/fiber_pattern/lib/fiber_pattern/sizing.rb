# frozen_string_literal: true

module FiberPattern
  # Calculates pattern sizing values from a provided gauge object.
  class Sizing
    # @return [Object] gauge object that responds to `required_stitches`
    attr_reader :gauge

    # @return [FiberPattern::Repeat, nil] optional stitch repeat to round stitch counts to
    attr_reader :repeat

    # @param gauge [Object] gauge object used to derive stitch counts
    # @param repeat [FiberPattern::Repeat, nil] optional stitch repeat to round stitch counts to
    def initialize(gauge:, repeat: nil)
      @gauge = gauge
      @repeat = repeat
    end

    # Calculates the number of stitches required to reach a given width, based on the provided gauge.
    #
    # @param width [Object] desired finished width in units accepted by the gauge
    # @return [Integer] number of stitches required to reach the requested width
    def cast_on_for(width)
      stitches = gauge.required_stitches(width)

      return stitches unless repeat

      repeat.adjust(stitches)
    end

    # Calculates the width of a given stitch count, based on the provided gauge.
    # @param stitches [FiberUnits::Stitches] stitch count to calculate width for
    # @return [Object] width in units accepted by the gauge
    def width_for(stitches)
      gauge.width_for_stitches(stitches)
    end
  end
end
