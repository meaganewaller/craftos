class GaugeService
  attr_reader :gauge

  def initialize(stitches:, rows:, width:, height: nil, unit: nil)
    @unit = unit || "inches"

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

  def stitches_for(width, repeat: nil, offset: 0)
    sizing_opts = {gauge: gauge}

    if repeat && repeat > 0
      sizing_opts[:stitch_repeat] = repeat.stitches
      sizing_opts[:repeat_offset] = offset.stitches
    end

    sizing = FiberPattern::Sizing.new(**sizing_opts)
    sizing.cast_on_for(width.to_f.public_send(@unit)).value
  end

  def rows_for(height)
    gauge.required_rows(height.to_f.public_send(@unit)).value
  end

  private
end
