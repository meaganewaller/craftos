module YarnSkein
  # Maps yardage density to conventional yarn weight categories.
  module WeightCategory
    # Yardage-per-100g ranges for each supported weight category.
    CATEGORY_RANGES = {
      lace: 800..Float::INFINITY,
      fingering: 350...800,
      sport: 300...350,
      dk: 220...300,
      worsted: 180...220,
      aran: 140...180,
      bulky: 100...140,
      super_bulky: 0...100
    }.freeze

    module_function

    # Find the closest standard weight category for a yarn's yardage density.
    #
    # @param yards_per_100g [Numeric]
    # @return [Symbol, nil]
    def for(yards_per_100g)
      CATEGORY_RANGES.each do |category, range|
        return category if range.cover?(yards_per_100g)
      end

      nil
    end
  end
end
