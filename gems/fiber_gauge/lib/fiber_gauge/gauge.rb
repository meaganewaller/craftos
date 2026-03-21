module FiberGauge
  class Gauge
    attr_reader :stitches, :rows, :width

    def initialize(stitches:, rows:, width:)
      @stitches = stitches
      @rows = rows
      @width = width
    end

    def spi
      stitches.value / width.to(:inches).value
    end

    def rpi
      rows.value / width.to(:inches).value
    end

    def width_for_stitches(stitch_count)
      stitches_per_inch = spi
      inches = stitch_count.value / stitches_per_inch

      inches.inches
    end

    def required_stitches(length)
      inches = length.to(:inches).value
      count = (inches * spi).round

      count.stitches
    end

    def required_rows(length)
      inches = length.to(:inches).value
      count = (inches * rpi).round

      count.rows
    end
  end
end
