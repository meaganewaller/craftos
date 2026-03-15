module FiberUnits
  module Conversions
    # Stateless conversion helper for supported weight units.
    module WeightConversion
      # Supported weight units mapped to gram conversion factors.
      FACTORS = {
        grams: 1.0,
        kilograms: 1000.0,
        ounces: 28.3495,
        pounds: 453.592
      }.freeze

      # Convert a numeric weight value between supported units.
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
