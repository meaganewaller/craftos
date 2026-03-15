module FiberUnits
  # Conversion tables and helpers for measurement dimensions.
  module Conversions
    # Stateless conversion helper for supported length units.
    module LengthConversion
      # Supported length units mapped to millimeter conversion factors.
      FACTORS = {
        millimeters: 1.0,
        centimeters: 10.0,
        meters: 1000.0,
        inches: 25.4,
        feet: 304.8,
        yards: 914.4
      }.freeze

      # Convert a numeric length value between supported units.
      #
      # @param value [Numeric]
      # @param from [Symbol]
      # @param to [Symbol]
      # @return [Numeric]
      # @raise [FiberUnits::InvalidUnitError] if either unit is unsupported
      def self.convert(value, from, to)
        raise FiberUnits::InvalidUnitError unless FACTORS.key?(from)
        raise FiberUnits::InvalidUnitError unless FACTORS.key?(to)

        base = value * FACTORS[from]
        base / FACTORS[to]
      end
    end
  end
end
