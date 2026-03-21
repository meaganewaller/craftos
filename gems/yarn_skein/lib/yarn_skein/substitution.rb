module YarnSkein
  class Substitution
    DEFAULT_TOLERANCE = 0.15

    attr_reader :target, :catalog

    def initialize(target:, catalog:)
      @target = target
      @catalog = catalog
    end

    def matches(tolerance: DEFAULT_TOLERANCE, fiber: nil)
      catalog.select do |yarn|
        next false if yarn == target
        next false unless yarn.weight_category == target.weight_category
        next false unless within_grist_tolerance?(yarn, tolerance)
        next false if fiber && !yarn.fiber_content&.contains?(fiber)

        true
      end
    end

    private

    def within_grist_tolerance?(yarn, tolerance)
      ratio = yarn.yards_per_100g / target.yards_per_100g.to_f
      ratio.between?(1.0 - tolerance, 1.0 + tolerance)
    end
  end
end
