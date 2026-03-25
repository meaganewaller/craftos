# frozen_string_literal: true

module FiberPattern
  # Standard size chart based on Craft Yarn Council (CYC) guidelines.
  #
  # Provides lookup of standard body measurements by size, and a closest-size
  # finder that matches body measurements to the nearest standard size.
  #
  # @example
  #   chart = FiberPattern::SizeChart.new
  #   chart.size(:m)          # => { bust: 36.inches, waist: 28.inches, hip: 38.inches }
  #   chart.closest_size(bust: 37.inches, waist: 29.inches, hip: 39.inches) # => :m
  class SizeChart
    # CYC standard women's body measurements (inches).
    # Source: Craft Yarn Council Standards & Guidelines
    CYC_WOMEN = {
      xs: {bust: 28, waist: 20, hip: 30},
      s: {bust: 32, waist: 24, hip: 34},
      m: {bust: 36, waist: 28, hip: 38},
      l: {bust: 40, waist: 32, hip: 42},
      xl: {bust: 44, waist: 36, hip: 46},
      xxl: {bust: 48, waist: 40, hip: 50},
      xxxl: {bust: 52, waist: 44, hip: 54},
      xxxxl: {bust: 56, waist: 48, hip: 58},
      xxxxxl: {bust: 60, waist: 52, hip: 62}
    }.freeze

    # @return [Hash<Symbol, Hash<Symbol, FiberUnits::Length>>] size chart data
    attr_reader :chart

    # @return [Array<Symbol>] ordered size names
    attr_reader :sizes

    # Creates a new size chart.
    #
    # @param chart [Hash<Symbol, Hash<Symbol, Numeric>>] raw chart data mapping size names
    #   to measurement hashes. Values are converted to inches. Defaults to CYC_WOMEN.
    def initialize(chart: CYC_WOMEN)
      @chart = chart.each_with_object({}) do |(size_name, measurements), result|
        result[size_name] = measurements.transform_values { |v| v.is_a?(Numeric) ? v.inches : v }
      end.freeze
      @sizes = @chart.keys.freeze
    end

    # Returns body measurements for a standard size.
    #
    # @param name [Symbol] size name
    # @return [Hash<Symbol, FiberUnits::Length>]
    # @raise [ArgumentError] if the size is not in the chart
    def size(name)
      raise ArgumentError, "unknown size #{name.inspect}" unless chart.key?(name)

      chart[name]
    end

    # Finds the closest standard size to the given body measurements.
    #
    # Compares using the sum of squared differences across all provided
    # measurements. Only measurements present in both the query and the
    # chart are compared.
    #
    # @param measurements [Hash<Symbol, FiberUnits::Length>] body measurements to match
    # @return [Symbol] the closest size name
    # @raise [ArgumentError] if no measurements overlap with the chart
    def closest_size(**measurements)
      comparable_keys = measurements.keys & chart.values.first.keys
      raise ArgumentError, "no comparable measurements provided" if comparable_keys.empty?

      sizes.min_by do |size_name|
        size_data = chart[size_name]
        comparable_keys.sum do |key|
          diff = measurements[key].value - size_data[key].value
          diff * diff
        end
      end
    end

    # Returns a BodyMeasurements object for a standard size.
    #
    # @param name [Symbol] size name
    # @return [FiberPattern::BodyMeasurements]
    def body_measurements_for(name)
      BodyMeasurements.new(**size(name))
    end
  end
end
