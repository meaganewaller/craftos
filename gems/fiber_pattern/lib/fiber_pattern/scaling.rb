# frozen_string_literal: true

module FiberPattern
  # Converts stitch and row counts from a pattern gauge to a knitter's gauge.
  class Scaling
    # Scales a stitch count to preserve width at a different stitches-per-inch rate.
    #
    # @param stitches [FiberUnits::Stitches] stitch count written for the pattern gauge
    # @param pattern_gauge [FiberGauge::Gauge] gauge used by the source pattern
    # @param knitter_gauge [FiberGauge::Gauge] gauge achieved by the knitter
    # @return [FiberUnits::Stitches] adjusted stitch count for the knitter's gauge
    def self.scale_stitches(stitches, pattern_gauge, knitter_gauge)
      pattern_spi = pattern_gauge.spi
      knitter_spi = knitter_gauge.spi

      scaled =
        (stitches.value * knitter_spi / pattern_spi).round

      scaled.stitches
    end

    # Scales a row count to preserve length at a different rows-per-inch rate.
    #
    # @param rows [FiberUnits::Rows] row count written for the pattern gauge
    # @param pattern_gauge [FiberGauge::Gauge] gauge used by the source pattern
    # @param knitter_gauge [FiberGauge::Gauge] gauge achieved by the knitter
    # @return [FiberUnits::Rows] adjusted row count for the knitter's gauge
    def self.scale_rows(rows, pattern_gauge, knitter_gauge)
      pattern_rpi = pattern_gauge.rpi
      knitter_rpi = knitter_gauge.rpi

      scaled =
        (rows.value * knitter_rpi / pattern_rpi).round

      scaled.rows
    end
  end
end
