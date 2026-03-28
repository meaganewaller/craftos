# frozen_string_literal: true

module YarnSkein
  # Estimates per-color yarn yardage for colorwork techniques.
  #
  # Supports stranded (Fair Isle) and intarsia colorwork. Stranded colorwork
  # adds a float overhead factor because unused colors are carried across the
  # back of the fabric. Intarsia uses separate yarn sections with no floats.
  #
  # @example Stranded colorwork
  #   estimator = YarnSkein::ColorworkEstimator.new(
  #     gauge: gauge,
  #     technique: :stranded
  #   )
  #   estimator.estimate(
  #     width: 40.inches, height: 24.inches,
  #     colors: { main: 0.60, contrast: 0.40 },
  #     yarn: yarn
  #   )
  #
  # @example Intarsia colorwork
  #   estimator = YarnSkein::ColorworkEstimator.new(
  #     gauge: gauge,
  #     technique: :intarsia
  #   )
  #   estimator.estimate(
  #     width: 40.inches, height: 24.inches,
  #     colors: { left: 0.50, right: 0.50 },
  #     yarn: yarn
  #   )
  class ColorworkEstimator
    TECHNIQUES = %i[stranded intarsia].freeze

    # Default float overhead for stranded colorwork (20%).
    DEFAULT_FLOAT_OVERHEAD = 0.20

    # Default safety margin (10%), consistent with YardageEstimator.
    DEFAULT_MARGIN = 0.10

    # @return [FiberGauge::Gauge]
    attr_reader :gauge

    # @return [Symbol] :stranded or :intarsia
    attr_reader :technique

    # @param gauge [FiberGauge::Gauge] gauge swatch data
    # @param technique [Symbol] :stranded or :intarsia
    def initialize(gauge:, technique:)
      unless TECHNIQUES.include?(technique)
        raise ArgumentError, "technique must be one of: #{TECHNIQUES.join(", ")}"
      end

      @gauge = gauge
      @technique = technique
    end

    # Estimates per-color yardage for a colorwork piece.
    #
    # @param width [FiberUnits::Length] finished width
    # @param height [FiberUnits::Length] finished height
    # @param colors [Hash<Symbol, Float>] color name => proportion (must sum to 1.0)
    # @param yarn [YarnSkein::Yarn, nil] yarn for skein calculations
    # @param margin [Float] safety margin (default 10%)
    # @param float_overhead [Float] extra yarn for floats in stranded work (default 20%)
    # @return [Hash] per-color breakdown and total
    def estimate(width:, height:, colors:, yarn: nil, margin: DEFAULT_MARGIN, float_overhead: DEFAULT_FLOAT_OVERHEAD)
      validate_colors!(colors)

      base_yardage = base_yardage_for(width, height, margin: 0.0)
      result = {}
      total_yards = 0.0

      colors.each do |color_name, proportion|
        color_yards = base_yardage * proportion
        color_yards *= (1.0 + float_overhead) if technique == :stranded
        color_yards *= (1.0 + margin)
        total_yards += color_yards

        entry = {yardage: color_yards.yards}
        entry[:skeins] = yarn.skeins_required(color_yards.yards) if yarn
        result[color_name] = entry
      end

      result[:total] = {yardage: total_yards.yards}
      result
    end

    private

    # Compute raw yardage (in float yards) for a rectangle with no margin.
    def base_yardage_for(width, height, margin:)
      stitches = gauge.required_stitches(width)
      rows = gauge.required_rows(height)
      total_stitches = stitches.value * rows.value

      total_stitches * yards_per_stitch
    end

    # Yards of yarn consumed per stitch, using the geometric U-loop model.
    def yards_per_stitch
      stitch_width_in = 1.0 / gauge.spi
      stitch_height_in = 1.0 / gauge.rpi
      (stitch_width_in + (2.0 * stitch_height_in)) / 36.0
    end

    def validate_colors!(colors)
      raise ArgumentError, "colors must be a non-empty Hash" unless colors.is_a?(Hash) && !colors.empty?

      total = colors.values.sum
      unless (total - 1.0).abs < 0.001
        raise ArgumentError, "color proportions must sum to 1.0 (got #{total})"
      end

      colors.each do |name, proportion|
        unless proportion.is_a?(Numeric) && proportion > 0
          raise ArgumentError, "proportion for #{name} must be a positive number"
        end
      end
    end
  end
end
