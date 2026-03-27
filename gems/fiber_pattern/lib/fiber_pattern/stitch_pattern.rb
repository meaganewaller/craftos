# frozen_string_literal: true

module FiberPattern
  # Models how a stitch pattern affects fabric dimensions and yarn consumption
  # relative to stockinette. Cables compress width and consume more yarn;
  # lace opens up fabric and uses less yarn per area.
  class StitchPattern
    # @return [String] human-readable name of the stitch pattern
    attr_reader :name

    # @return [FiberPattern::Repeat, nil] optional stitch repeat for this pattern
    attr_reader :repeat

    # @return [Float] multiplier vs stockinette for fabric width (< 1 = pulls in)
    attr_reader :width_factor

    # @return [Float] multiplier vs stockinette for yarn consumption (> 1 = uses more)
    attr_reader :yarn_factor

    # @param name [String] human-readable name of the stitch pattern
    # @param repeat [FiberPattern::Repeat, nil] optional stitch repeat
    # @param width_factor [Float] width multiplier vs stockinette (default: 1.0)
    # @param yarn_factor [Float] yarn consumption multiplier vs stockinette (default: 1.0)
    def initialize(name:, repeat: nil, width_factor: 1.0, yarn_factor: 1.0)
      @name = name.freeze
      @repeat = repeat
      @width_factor = width_factor.to_f
      @yarn_factor = yarn_factor.to_f
      validate!
    end

    # Returns the stockinette-equivalent width needed to achieve the desired
    # finished width in this stitch pattern.
    #
    # @param width [FiberUnits::Length] desired finished width
    # @return [FiberUnits::Length] stockinette-equivalent width to knit
    def adjust_width(width)
      (width.value / width_factor).round(2).public_send(width.unit)
    end

    # Adjusts a base yardage estimate to account for this pattern's yarn consumption.
    #
    # @param yardage [FiberUnits::Length] base yardage assuming stockinette
    # @return [FiberUnits::Length] adjusted yardage for this stitch pattern
    def adjust_yardage(yardage)
      (yardage.value * yarn_factor).round(2).public_send(yardage.unit)
    end

    # Preset definitions for common stitch patterns.

    def self.stockinette
      new(name: "Stockinette", width_factor: 1.0, yarn_factor: 1.0)
    end

    def self.garter
      new(name: "Garter", width_factor: 1.0, yarn_factor: 1.05)
    end

    def self.rib_1x1
      new(
        name: "1x1 Rib",
        repeat: Repeat.new(multiple: 2.stitches),
        width_factor: 0.90,
        yarn_factor: 1.10
      )
    end

    def self.rib_2x2
      new(
        name: "2x2 Rib",
        repeat: Repeat.new(multiple: 4.stitches),
        width_factor: 0.85,
        yarn_factor: 1.12
      )
    end

    def self.seed
      new(
        name: "Seed Stitch",
        repeat: Repeat.new(multiple: 2.stitches),
        width_factor: 0.95,
        yarn_factor: 1.05
      )
    end

    # Crochet preset definitions.

    def self.single_crochet
      new(name: "Single Crochet", width_factor: 1.0, yarn_factor: 1.0)
    end

    def self.half_double_crochet
      new(name: "Half Double Crochet", width_factor: 1.05, yarn_factor: 1.15)
    end

    def self.double_crochet
      new(name: "Double Crochet", width_factor: 1.10, yarn_factor: 1.25)
    end

    def self.treble_crochet
      new(name: "Treble Crochet", width_factor: 1.15, yarn_factor: 1.35)
    end

    def self.moss_stitch
      new(
        name: "Moss Stitch",
        repeat: Repeat.new(multiple: 2.stitches),
        width_factor: 1.05,
        yarn_factor: 1.10
      )
    end

    def self.shell_stitch
      new(
        name: "Shell Stitch",
        repeat: Repeat.new(multiple: 6.stitches, offset: 1.stitches),
        width_factor: 1.15,
        yarn_factor: 1.30
      )
    end

    def self.v_stitch
      new(
        name: "V-Stitch",
        repeat: Repeat.new(multiple: 2.stitches),
        width_factor: 1.10,
        yarn_factor: 0.90
      )
    end

    private

    def validate!
      raise ArgumentError, "name must be a non-empty string" if name.nil? || name.empty?
      raise ArgumentError, "width_factor must be positive" unless width_factor.positive?
      raise ArgumentError, "yarn_factor must be positive" unless yarn_factor.positive?
    end
  end
end
