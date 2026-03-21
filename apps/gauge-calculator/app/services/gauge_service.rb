class GaugeService
  attr_reader :gauge

  def initialize(stitches:, rows:, width:, unit: nil)
    @unit = unit || "inches"
    @gauge = FiberGauge::Gauge.new(
      stitches: stitches.stitches,
      rows: rows.rows,
      width: width.to_f.public_send(@unit)
    )
  end

  def results
    {
      spi: gauge.spi,
      rpi: gauge.rpi
    }
  end

  def stitches_for(width)
    gauge.required_stitches(width.to_f.public_send(@unit)).value
  end

  def rows_for(height)
    gauge.required_rows(height.to_f.public_send(@unit)).value
  end
end
