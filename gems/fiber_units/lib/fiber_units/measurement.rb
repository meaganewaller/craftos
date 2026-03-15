module FiberUnits
  # Base class for unit-aware measurements such as length and weight.
  #
  # Subclasses define a `FACTORS` constant that maps supported unit names
  # to their multiplier in the dimension's base unit. Instances are immutable
  # value objects that support arithmetic, comparison, and conversion while
  # preserving dimension safety.
  class Measurement
    include Comparable

    attr_reader :value, :unit

    # @param value [Numeric] numeric magnitude in the supplied unit
    # @param unit [Symbol] unit identifier present in the subclass factor table
    def initialize(value, unit)
      @value = value
      @unit = unit
    end

    # Add another measurement of the same dimension.
    #
    # The operation is performed in base units and returned in the receiver's unit.
    #
    # @param other [Measurement]
    # @return [Measurement]
    # @raise [FiberUnits::DimensionError] if the measurement dimensions differ
    def +(other)
      ensure_same_dimension!(other)

      base = to_base + other.to_base
      new_value = base / self.class::FACTORS[unit]
      new_value = new_value.round(12)

      self.class.new(new_value, unit)
    end

    # Subtract another measurement of the same dimension.
    #
    # The operation is performed in base units and returned in the receiver's unit.
    #
    # @param other [Measurement]
    # @return [Measurement]
    # @raise [FiberUnits::DimensionError] if the measurement dimensions differ
    def -(other)
      ensure_same_dimension!(other)

      base = to_base - other.to_base
      new_value = base / self.class::FACTORS[unit]
      new_value = new_value.round(12)

      self.class.new(new_value, unit)
    end

    # Scale the measurement by a numeric value.
    #
    # @param other [Numeric]
    # @return [Measurement]
    def *(other)
      self.class.new(value * other, unit)
    end

    # Divide the measurement by a scalar or another measurement.
    #
    # Dividing by a measurement returns a {FiberUnits::Ratio}. Dividing by a
    # scalar returns a new measurement in the same unit.
    #
    # @param other [Numeric, Measurement]
    # @return [Measurement, Ratio]
    def /(other)
      if other.is_a?(Measurement)
        Ratio.new(self, other)
      else
        self.class.new(value / other, unit)
      end
    end

    # Compare two measurements of the same dimension.
    #
    # @param other [Measurement]
    # @return [-1, 0, 1, nil]
    # @raise [FiberUnits::DimensionError] if the measurement dimensions differ
    def <=>(other)
      ensure_same_dimension!(other)
      to_base <=> other.to_base
    end

    # Check value equality across units within the same dimension.
    #
    # @param other [Object]
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(Measurement)
      return false unless other.is_a?(self.class)

      (to_base - other.to_base).abs < 1e-10
    end

    # Negated equality predicate.
    #
    # @param other [Object]
    # @return [Boolean]
    def !=(other)
      !(self == other)
    end

    # Convert the measurement to another supported unit in the same dimension.
    #
    # @param target_unit [Symbol]
    # @return [Measurement]
    # @raise [FiberUnits::InvalidUnitError] if the target unit is unsupported
    def to(target_unit)
      raise FiberUnits::InvalidUnitError unless self.class::FACTORS.key?(target_unit)

      base = to_base
      self.class.new(base / self.class::FACTORS[target_unit], target_unit)
    end

    # Convert the measurement into its dimension's base unit value.
    #
    # @return [Numeric]
    # @raise [NotImplementedError] if the subclass does not define `FACTORS`
    def to_base
      raise NotImplementedError unless self.class.const_defined?(:FACTORS)

      value * self.class::FACTORS[unit]
    end

    # Build a measurement from a value in the subclass base unit.
    #
    # @param base_value [Numeric]
    # @return [Measurement]
    # @raise [FiberUnits::InvalidUnitError] if the subclass has no declared base unit
    def self.from_base(base_value)
      factors = self::FACTORS

      base_unit = factors.key(1.0)

      raise FiberUnits::InvalidUnitError unless base_unit

      new(base_value / factors[base_unit], base_unit)
    end

    private

    # @param other [Object]
    # @return [void]
    # @raise [FiberUnits::DimensionError] if the measurement dimensions differ
    def ensure_same_dimension!(other)
      unless other.is_a?(self.class)
        raise FiberUnits::DimensionError,
          "Cannot combine #{self.class} with #{other.class}"
      end
    end
  end
end
