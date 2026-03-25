# frozen_string_literal: true

module FiberPattern
  # Applies grade rules to a base size's measurements to produce a full size range.
  #
  # @example
  #   grader = FiberPattern::Grader.new(
  #     base_size: :m,
  #     measurements: { bust: 36.inches, waist: 30.inches },
  #     rules: grade_rules
  #   )
  #   grader.size(:l)     # => { bust: 38.inches, waist: 32.inches }
  #   grader.all_sizes    # => { xs: {...}, s: {...}, ... }
  class Grader
    # Standard size progression from smallest to largest.
    SIZES = %i[xs s m l xl xxl xxxl xxxxl xxxxxl].freeze

    # @return [Symbol] the base size used as the grading anchor
    # @return [Hash<Symbol, FiberUnits::Length>] base measurements
    # @return [FiberPattern::GradeRules] grading rules
    attr_reader :base_size, :measurements, :rules

    # @param base_size [Symbol] one of the standard SIZES
    # @param measurements [Hash<Symbol, FiberUnits::Length>] base size measurements
    # @param rules [FiberPattern::GradeRules] grade rules to apply
    # @param sizes [Array<Symbol>] optional custom size list (defaults to SIZES)
    def initialize(base_size:, measurements:, rules:, sizes: SIZES)
      @sizes = sizes
      validate!(base_size, measurements, rules)
      @base_size = base_size
      @measurements = measurements.freeze
      @rules = rules
    end

    # Returns graded measurements for a single size.
    #
    # @param target [Symbol] the size to compute
    # @return [Hash<Symbol, FiberUnits::Length>]
    # @raise [ArgumentError] if the target size is not in the size list
    def size(target)
      raise ArgumentError, "unknown size #{target.inspect}" unless @sizes.include?(target)

      offset = @sizes.index(target) - @sizes.index(base_size)

      measurements.each_with_object({}) do |(name, base_value), result|
        step = rules.step_for(name)
        result[name] = base_value + (step * offset)
      end
    end

    # Returns graded measurements for all sizes.
    #
    # @return [Hash<Symbol, Hash<Symbol, FiberUnits::Length>>]
    def all_sizes
      @sizes.each_with_object({}) do |size_name, result|
        result[size_name] = size(size_name)
      end
    end

    private

    def validate!(base_size, measurements, rules)
      unless @sizes.include?(base_size)
        raise ArgumentError, "base_size #{base_size.inspect} is not in the size list"
      end

      measurements.each_key do |name|
        unless rules.measurements.include?(name)
          raise ArgumentError, "no grade rule for measurement #{name.inspect}"
        end
      end
    end
  end
end
