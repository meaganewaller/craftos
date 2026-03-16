class GaugeService
  def initialize(stitches:, rows:, width:)
    @gauge = FiberGauge::Gauge.new(
      stitches: stitches.stitches,
      rows: rows.rows,
      width: width.inches
    )
  end

  def results
    {
      spi: @gauge.spi,
      rpi: @gauge.rpi,
    }
  end

  def stitches_for(width)
    @gauge.required_stitches(width.inches).value
  end

  def rows_for(height)
    @gauge.required_rows(height.inches).value
  end
end
