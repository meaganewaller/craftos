module YarnSkein
  # Value object describing a yarn line and one skein's physical properties.
  #
  # Yardage and weight are stored as `fiber_units` measurements so related
  # calculations remain unit-safe.
  class Yarn
    attr_reader :brand, :line, :yardage, :skein_weight, :fiber_content

    # @param brand [String] yarn manufacturer or brand name
    # @param line [String] product line name
    # @param yardage [FiberUnits::Length] yardage contained in one skein
    # @param skein_weight [FiberUnits::Weight] weight of one skein
    # @param fiber_content [FiberBlend, nil] optional fiber composition details
    # @raise [ArgumentError] if yardage or skein weight are not typed fiber_units values
    def initialize(brand:, line:, yardage:, skein_weight:, fiber_content: nil)
      raise ArgumentError, "yardage must be a FiberUnits::Length" unless yardage.is_a?(FiberUnits::Length)
      raise ArgumentError, "skein_weight must be a FiberUnits::Weight" unless skein_weight.is_a?(FiberUnits::Weight)

      @brand = brand
      @line = line
      @yardage = yardage
      @skein_weight = skein_weight
      @fiber_content = fiber_content
    end

    # Return the yarn grist as a ratio of yardage to weight.
    #
    # @return [FiberUnits::Ratio]
    def grist
      yardage / skein_weight
    end

    # Resolve the yarn's conventional weight category from its yardage density.
    #
    # @return [Symbol, nil]
    def weight_category
      YarnSkein::WeightCategory.for(yards_per_100g)
    end

    # Calculate how many yards this yarn yields per 100 grams.
    #
    # @return [Float]
    def yards_per_100g
      grams = skein_weight.to(:grams).value
      yards = yardage.to(:yards).value

      (yards / grams) * 100
    end

    # Compare this yarn's density to another yarn within a 15% tolerance.
    #
    # @param other [Yarn]
    # @return [Boolean]
    def similar_weight_to?(other)
      ratio = yards_per_100g / other.yards_per_100g.to_f
      ratio.between?(0.85, 1.15)
    end

    # Calculate how many skeins are needed to satisfy a target yardage.
    #
    # @param required_yardage [FiberUnits::Length]
    # @return [Integer]
    # @raise [ArgumentError] if the argument is not a typed length value
    def skeins_required(required_yardage)
      unless required_yardage.is_a?(FiberUnits::Length)
        raise ArgumentError, "required_yardage must be a FiberUnits::Length"
      end

      yards_needed = required_yardage.to(:yards).value
      yards_per_skein = yardage.to(:yards).value

      (yards_needed / yards_per_skein).ceil
    end

    # Calculate the total yardage provided by a number of skeins.
    #
    # @param skein_count [Numeric]
    # @return [FiberUnits::Length]
    # @raise [ArgumentError] if the skein count is not positive
    def total_yardage(skein_count)
      unless skein_count.is_a?(Numeric) && skein_count > 0
        raise ArgumentError, "skein_count must be positive"
      end

      yardage * skein_count
    end

    # Compare yarn identity by brand, line, yardage, and skein weight.
    #
    # @param other [Object]
    # @return [Boolean]
    def ==(other)
      other.is_a?(Yarn) &&
        brand == other.brand &&
        line == other.line &&
        yardage == other.yardage &&
        skein_weight == other.skein_weight
    end
  end
end
