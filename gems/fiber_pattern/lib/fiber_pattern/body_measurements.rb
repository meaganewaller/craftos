# frozen_string_literal: true

module FiberPattern
  # Value object representing key body dimensions.
  #
  # Accepts any set of named measurements as keyword arguments.
  # Each value should be a FiberUnits::Length.
  #
  # @example
  #   body = FiberPattern::BodyMeasurements.new(
  #     bust: 36.inches,
  #     waist: 30.inches,
  #     hip: 38.inches,
  #     arm_length: 24.inches
  #   )
  #   body.bust       # => 36.inches
  #   body[:waist]    # => 30.inches
  #   body.measurements # => [:bust, :waist, :hip, :arm_length]
  class BodyMeasurements
    # @return [Hash<Symbol, FiberUnits::Length>] all measurements
    attr_reader :data

    # @param measurements [Hash<Symbol, FiberUnits::Length>] named body measurements
    def initialize(**measurements)
      raise ArgumentError, "at least one measurement is required" if measurements.empty?

      @data = measurements.freeze
      define_accessors!
    end

    # Returns the measurement names.
    #
    # @return [Array<Symbol>]
    def measurements
      data.keys
    end

    # Hash-style access to a measurement.
    #
    # @param name [Symbol]
    # @return [FiberUnits::Length, nil]
    def [](name)
      data[name]
    end

    # Returns measurements as a plain hash.
    #
    # @return [Hash<Symbol, FiberUnits::Length>]
    def to_h
      data.dup
    end

    private

    def define_accessors!
      data.each_key do |name|
        define_singleton_method(name) { data[name] }
      end
    end
  end
end
