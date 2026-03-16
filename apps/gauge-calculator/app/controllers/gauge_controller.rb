class GaugeController < ApplicationController
  def calculate
    gauge = build_gauge

    render json: {
      spi: gauge.spi,
      rpi: gauge.rpi
    }
  end

  def stitches
    gauge = build_gauge

    stitches = gauge.required_stitches(
      length_param(:target_width)
    )

    render json: {
      stitches: stitches.value
    }
  end

  def rows
    gauge = build_gauge

    rows = gauge.required_rows(
      length_param(:target_height)
    )

    render json: {
      rows: rows.value
    }
  end

  private

  def build_gauge
    FiberGauge::Gauge.new(
      stitches: params[:stitches].to_i.stitches,
      rows: params[:rows].to_i.rows,
      width: length_param(:width)
    )
  end

  def length_param(key)
    value = params[key].to_f
    unit = params[:unit] || "inches"

    value.public_send(unit)
  end
end
