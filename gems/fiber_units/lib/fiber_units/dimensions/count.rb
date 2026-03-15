module FiberUnits
  # Base class for count-based dimensions such as stitches and rows.
  #
  # Counts behave like immutable typed integers. Arithmetic is only allowed
  # between instances of the exact same subclass to prevent mixing stitch and
  # row counts accidentally.
  class Count
    include Comparable

    attr_reader :value

    # @param value [Numeric] number of counted items
    # @param _unit [Object] ignored placeholder to align with measurement APIs
    def initialize(value, _unit = nil)
      @value = value
      freeze
    end

    # Add another count of the same subclass.
    #
    # @param other [Count]
    # @return [Count]
    # @raise [FiberUnits::DimensionError] if the counts are different subclasses
    def +(other)
      ensure_same_class!(other)
      self.class.new(value + other.value)
    end

    # Subtract another count of the same subclass.
    #
    # @param other [Count]
    # @return [Count]
    # @raise [FiberUnits::DimensionError] if the counts are different subclasses
    def -(other)
      ensure_same_class!(other)
      self.class.new(value - other.value)
    end

    # Scale the count by a numeric multiplier.
    #
    # @param other [Numeric]
    # @return [Count]
    def *(other)
      self.class.new(value * other)
    end

    # Return the raw count value as an integer-like number.
    #
    # @return [Numeric]
    def to_i
      value
    end

    # Compare two counts of the same subclass.
    #
    # @param other [Count]
    # @return [-1, 0, 1, nil]
    def <=>(other)
      return nil unless other.instance_of?(self.class)
      value <=> other.value
    end

    # Check whether another count has the same type and value.
    #
    # @param other [Object]
    # @return [Boolean]
    def ==(other)
      other.class == self.class && other.value == value
    end

    private

    # @param other [Object]
    # @return [void]
    # @raise [FiberUnits::DimensionError] if the counts are different subclasses
    def ensure_same_class!(other)
      unless other.instance_of?(self.class)
        raise FiberUnits::DimensionError,
          "Cannot combine #{self.class} with #{other.class}"
      end
    end
  end
end
