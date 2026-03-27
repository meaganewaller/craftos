class SubstitutionService
  attr_reader :target, :catalog

  def initialize(target_attrs:, catalog: nil, catalog_data: nil)
    @target = build_yarn(**target_attrs)
    @catalog = if catalog
      catalog.select { |y| y.is_a?(YarnSkein::Yarn) }
    else
      (catalog_data || []).map { |attrs| build_yarn(**attrs) }
    end
  end

  def matches(tolerance: nil, fiber: nil)
    sub = YarnSkein::Substitution.new(target: target, catalog: catalog)
    opts = {}
    opts[:tolerance] = tolerance if tolerance
    opts[:fiber] = fiber if fiber
    results = sub.matches(**opts)
    results.sort_by { |yarn| grist_distance(yarn) }
  end

  def target_info
    info = {
      weight_category: target.weight_category,
      yards_per_100g: target.yards_per_100g.round(1),
      grist: target.grist.value.round(2)
    }
    info[:fiber_content] = target.fiber_content.fibers if target.fiber_content
    info
  end

  private

  def grist_distance(yarn)
    (yarn.yards_per_100g - target.yards_per_100g).abs
  end

  def build_yarn(yardage:, skein_weight:, brand: "Unknown", line: "Unknown", fiber_content: nil)
    fc = fiber_content ? YarnSkein::FiberBlend.new(fiber_content) : nil
    YarnSkein::Yarn.new(
      brand: brand,
      line: line,
      yardage: yardage.to_f.yards,
      skein_weight: skein_weight.to_f.grams,
      fiber_content: fc
    )
  end
end
