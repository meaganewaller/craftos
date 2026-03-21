class GaugeService
  attr_reader :gauge

  def initialize(stitches:, rows:, width:, height: nil, unit: nil)
    @unit = unit || "inches"
    @stitch_count = stitches
    @row_count = rows

    @gauge = FiberGauge::Gauge.new(
      stitches: stitches.stitches,
      rows: rows.rows,
      width: width.to_f.public_send(@unit)
    )

    if height
      @row_gauge = FiberGauge::Gauge.new(
        stitches: stitches.stitches,
        rows: rows.rows,
        width: height.to_f.public_send(@unit)
      )
    end
  end

  def spi
    gauge.spi
  end

  def rpi
    row_gauge.rpi
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

  def row_gauge
    @row_gauge || @gauge
  end
end
