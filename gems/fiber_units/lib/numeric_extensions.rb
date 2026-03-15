module FiberUnits
  # Installs numeric helper methods so numbers can produce FiberUnits objects.
  #
  # After installation, Ruby Numeric values gain convenience methods
  # for constructing fiber-related units.
  #
  # @example Length units
  #   10.cm
  #   5.inches
  #
  # @example Weight units
  #   50.g
  #   100.grams
  #
  # @example Fiber counts
  #   200.stitches
  #   50.rows
  #
  # These helpers allow expressive, pattern-like calculations:
  #
  # @example
  #  gauge = 18.stitches / 4.inches
  #
  module NumericExtensions
    # Install all numeric extensions.
    #
    # This method dynamically adds unit methods to Ruby's `Numeric`
    # class based on the registered conversion tables.
    #
    # It is called automatically when the library loads.
    #
    # @return [void]
    def self.install!
      install_length_units
      install_weight_units
      install_fiber_counts
    end

    # Install numeric helpers for length units.
    #
    # Each unit defined in
    # {FiberUnits::Conversions::LengthConversion::FACTORS}
    # becomes a method on `Numeric`.
    #
    # @example
    #   10.cm
    #   5.inches
    #
    # @return [void]
    def self.install_length_units
      FiberUnits::Conversions::LengthConversion::FACTORS.keys.each do |unit|
        Numeric.define_method(unit) do
          FiberUnits::Length.new(self, unit)
        end
      end
    end

    # Install numeric helpers for weight units.
    #
    # Each unit defined in
    # {FiberUnits::Conversions::WeightConversion::FACTORS}
    # becomes a method on `Numeric`.
    #
    # @example
    #   50.g
    #   100.grams
    #
    # @return [void]
    def self.install_weight_units
      FiberUnits::Conversions::WeightConversion::FACTORS.keys.each do |unit|
        Numeric.define_method(unit) do
          FiberUnits::Weight.new(self, unit)
        end
      end
    end

    # Install numeric helpers for stitch and row counts.
    #
    # These helpers create count objects commonly used when
    # calculating knitting or crochet gauge.
    #
    # @example
    #   20.stitches
    #   10.rows
    #
    # @return [void]
    def self.install_fiber_counts
      Numeric.define_method(:stitches) do
        FiberUnits::StitchCount.new(self)
      end

      Numeric.define_method(:rows) do
        FiberUnits::RowCount.new(self)
      end
    end
  end
end

FiberUnits::NumericExtensions.install!

# ----
# YARD directives for dynamically defined methods
# ----

class Numeric
  # @!method millimeters
  #   Create a {FiberUnits::Length} measured in millimeters.
  #   @return [FiberUnits::Length]
  #
  # @!method centimeters
  #   Create a {FiberUnits::Length} measured in centimeters.
  #   @return [FiberUnits::Length]
  #
  # @!method meters
  #   Create a {FiberUnits::Length} measured in meters.
  #   @return [FiberUnits::Length]
  #
  # @!method inches
  #   Create a {FiberUnits::Length} measured in inches.
  #   @return [FiberUnits::Length]
  #
  # @!method feet
  #   Create a {FiberUnits::Length} measured in feet.
  #   @return [FiberUnits::Length]
  #
  # @!method yards
  #   Create a {FiberUnits::Length} measured in yards.
  #   @return [FiberUnits::Length]
  #
  # @!method grams
  #   Create a {FiberUnits::Weight} measured in grams.
  #   @return [FiberUnits::Weight]
  #
  # @!method kilograms
  #   Create a {FiberUnits::Weight} measured in kilograms.
  #   @return [FiberUnits::Weight]
  #
  # @!method ounces
  #   Create a {FiberUnits::Weight} measured in ounces.
  #   @return [FiberUnits::Weight]
  #
  # @!method pounds
  #   Create a {FiberUnits::Weight} measured in pounds.
  #   @return [FiberUnits::Weight]
  #
  # @!method stitches
  #   Create a stitch count.
  #   @return [FiberUnits::StitchCount]

  # @!method rows
  #   Create a row count.
  #   @return [FiberUnits::RowCount]
end
