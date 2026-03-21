class GaugeService
  attr_reader :gauge

  def initialize(stitches:, rows:, width:, height: nil, unit: nil)
    @unit = unit || "inches"
    @stitch_count = stitches
    @row_count = rows

    gauge_opts = {
      stitches: stitches.stitches,
      rows: rows.rows,
      width: width.to_f.public_send(@unit)
    }
    gauge_opts[:height] = height.to_f.public_send(@unit) if height

    @gauge = FiberGauge::Gauge.new(**gauge_opts)
  end

  def spi
    gauge.spi
  end

  def rpi
    gauge.rpi
  end

  def results
    {
      spi: spi,
      rpi: rpi
    }
  end

  def stitches_for(width)
    gauge.required_stitches(width.to_f.public_send(@unit)).value
  end

  def rows_for(height)
    gauge.required_rows(height.to_f.public_send(@unit)).value
  end

  private
end
