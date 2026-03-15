module FiberUnits
  # Represents a ratio between two measurements or counts.
  #
  # Ratios are commonly used for craft-specific calculations such as yarn
  # grist or gauge, where one unit is expressed relative to another.
  class Ratio
    attr_reader :numerator, :denominator

    # @param numerator [Measurement, Count]
    # @param denominator [Measurement, Count]
    def initialize(numerator, denominator)
      @numerator = numerator
      @denominator = denominator
    end

    # Return the numeric ratio between numerator and denominator.
    #
    # @return [Float]
    def value
      numerator.value.to_f / denominator.value
    end

    # Render the ratio with rounded value and unit labels.
    #
    # @return [String]
    def to_s
      "#{value.round(2)} #{numerator.unit}/#{denominator.unit}"
    end
  end
end
