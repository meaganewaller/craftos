# frozen_string_literal: true

module FiberPattern
  # Defines per-measurement step values used to grade a pattern across sizes.
  #
  # Each rule maps a measurement name to a step value (a FiberUnits::Length)
  # that represents how much that measurement changes between adjacent sizes.
  #
  # @example
  #   rules = FiberPattern::GradeRules.new(
  #     bust: { step: 2.inches },
  #     waist: { step: 2.inches },
  #     sleeve_length: { step: 0.5.inches }
  #   )
  #   rules.step_for(:bust) # => 2.inches
  class GradeRules
    # @return [Hash<Symbol, Hash>] raw rules keyed by measurement name
    attr_reader :rules

    # @param rules [Hash<Symbol, Hash>] measurement rules, each with a :step key
    def initialize(**rules)
      validate!(rules)
      @rules = rules.freeze
    end

    # Returns the step value for a given measurement.
    #
    # @param measurement [Symbol] measurement name
    # @return [FiberUnits::Length] step between adjacent sizes
    # @raise [ArgumentError] if the measurement has no rule defined
    def step_for(measurement)
      raise ArgumentError, "no rule defined for #{measurement.inspect}" unless rules.key?(measurement)

      rules[measurement][:step]
    end

    # Returns all measurement names that have rules defined.
    #
    # @return [Array<Symbol>]
    def measurements
      rules.keys
    end

    private

    def validate!(rules)
      rules.each do |name, config|
        unless config.is_a?(Hash) && config.key?(:step)
          raise ArgumentError, "rule for #{name.inspect} must be a Hash with a :step key"
        end
      end
    end
  end
end
