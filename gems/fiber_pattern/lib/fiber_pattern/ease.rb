# frozen_string_literal: true

module FiberPattern
  # Value object representing ease preferences per measurement.
  #
  # Ease is the difference between body measurements and finished garment
  # measurements. Positive ease creates a looser fit; negative ease creates
  # a tighter fit.
  #
  # @example
  #   ease = FiberPattern::Ease.new(
  #     bust: 4.inches,
  #     waist: 2.inches,
  #     hip: 2.inches
  #   )
  #   ease.bust        # => 4.inches
  #   ease[:waist]     # => 2.inches
  #   ease.for(:bust)  # => 4.inches
  class Ease
    # @return [Hash<Symbol, FiberUnits::Length>] all ease values
    attr_reader :data

    # @param ease_values [Hash<Symbol, FiberUnits::Length>] named ease values
    def initialize(**ease_values)
      raise ArgumentError, "at least one ease value is required" if ease_values.empty?

      @data = ease_values.freeze
      define_accessors!
    end

    # Returns the ease value for a given measurement.
    #
    # @param name [Symbol]
    # @return [FiberUnits::Length]
    # @raise [ArgumentError] if no ease is defined for the measurement
    def for(name)
      raise ArgumentError, "no ease defined for #{name.inspect}" unless data.key?(name)

      data[name]
    end

    # Hash-style access to an ease value.
    #
    # @param name [Symbol]
    # @return [FiberUnits::Length, nil]
    def [](name)
      data[name]
    end

    # Returns all measurement names that have ease defined.
    #
    # @return [Array<Symbol>]
    def measurements
      data.keys
    end

    # Returns ease values as a plain hash.
    #
    # @return [Hash<Symbol, FiberUnits::Length>]
    def to_h
      data.dup
    end

    private

    def define_accessors!
      data.each_key do |name|
        next if name == :for # avoid overriding #for

        define_singleton_method(name) { data[name] }
      end
    end
  end
end
