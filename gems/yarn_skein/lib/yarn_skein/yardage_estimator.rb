# frozen_string_literal: true

module YarnSkein
  # Estimates total yarn yardage required for a project based on gauge and yarn.
  #
  # Uses a geometric stitch model: each knit stitch consumes approximately
  # one stitch-width plus two stitch-heights of yarn (the U-shaped loop path).
  # This gives a reasonable estimate for stockinette and similar stitch patterns.
  #
  # @example
  #   estimator = YarnSkein::YardageEstimator.new(gauge: gauge, yarn: yarn)
  #   estimator.for_rectangle(width: 60.inches, height: 72.inches)
  #   # => { yardage: <FiberUnits::Length>, skeins: 10 }
  class YardageEstimator
    # Default safety margin added to yardage estimates (10%).
    DEFAULT_MARGIN = 0.10

    # @return [FiberGauge::Gauge] gauge used for stitch/row calculations
    attr_reader :gauge

    # @return [YarnSkein::Yarn] yarn used for skein calculations
    attr_reader :yarn

    # @param gauge [FiberGauge::Gauge] gauge swatch data
    # @param yarn [YarnSkein::Yarn] yarn being used
    def initialize(gauge:, yarn:)
      @gauge = gauge
      @yarn = yarn
    end

    # Estimates yardage for a rectangular piece (scarf, blanket, etc.).
    #
    # @param width [FiberUnits::Length] finished width
    # @param height [FiberUnits::Length] finished height
    # @param margin [Float] safety margin as a decimal (default 0.10 = 10%)
    # @return [Hash] :yardage [FiberUnits::Length] and :skeins [Integer]
    def for_rectangle(width:, height:, margin: DEFAULT_MARGIN)
      stitches = gauge.required_stitches(width)
      rows = gauge.required_rows(height)

      for_piece(stitches: stitches, rows: rows, margin: margin)
    end

    # Estimates yardage from stitch and row counts directly.
    #
    # @param stitches [FiberUnits::StitchCount] total stitches across
    # @param rows [FiberUnits::RowCount] total rows
    # @param margin [Float] safety margin as a decimal (default 0.10 = 10%)
    # @return [Hash] :yardage [FiberUnits::Length] and :skeins [Integer]
    def for_piece(stitches:, rows:, margin: DEFAULT_MARGIN)
      total_stitches = stitches.value * rows.value
      yardage = (total_stitches * yards_per_stitch * (1.0 + margin)).yards

      {yardage: yardage, skeins: yarn.skeins_required(yardage)}
    end

    # Returns the estimated yards of yarn consumed per stitch.
    #
    # Models each stitch as a U-shaped loop: one stitch-width across plus
    # two stitch-heights for the legs of the loop.
    #
    # @return [Float] yards per stitch
    def yards_per_stitch
      stitch_width_in = 1.0 / gauge.spi
      stitch_height_in = 1.0 / gauge.rpi
      yarn_per_stitch_in = stitch_width_in + (2.0 * stitch_height_in)

      yarn_per_stitch_in / 36.0
    end
  end
end
