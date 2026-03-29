class ProjectCheckService
  def initialize(user)
    @user = user
  end

  def check_rectangle(gauge_params:, dimensions:, stash_entry_ids:)
    entries = find_entries(stash_entry_ids)
    return {error: "No matching stash entries found"} if entries.empty?

    gauge = build_gauge(gauge_params)
    yarn = build_yarn(entries.first)

    estimator = YarnSkein::YardageEstimator.new(gauge: gauge, yarn: yarn)
    result = estimator.for_rectangle(
      width: dimensions[:width].to_f.inches,
      height: dimensions[:height].to_f.inches
    )

    estimated_yardage = result[:yardage].to(:yards).value.round(1)
    estimated_skeins = result[:skeins]
    available_yardage = entries.sum(&:total_yardage)
    sufficient = available_yardage >= estimated_yardage

    {
      mode: "simple",
      estimated_yardage: estimated_yardage,
      estimated_skeins: estimated_skeins,
      available_yardage: available_yardage,
      sufficient: sufficient,
      surplus: sufficient ? (available_yardage - estimated_yardage).round(1) : 0,
      shortage: sufficient ? 0 : (estimated_yardage - available_yardage).round(1)
    }
  end

  def check_colorwork(gauge_params:, dimensions:, technique:, color_assignments:)
    gauge = build_gauge(gauge_params)
    technique_sym = technique.to_s.to_sym

    colors = {}
    entry_map = {}

    color_assignments.each do |name, assignment|
      proportion = assignment["proportion"].to_f
      colors[name.to_sym] = proportion

      ids = Array(assignment["stash_entry_ids"]).map(&:to_i)
      entry_map[name.to_sym] = find_entries(ids)
    end

    representative_entries = entry_map.values.flatten
    yarn = representative_entries.any? ? build_yarn(representative_entries.first) : nil

    estimator = YarnSkein::ColorworkEstimator.new(gauge: gauge, technique: technique_sym)
    result = estimator.estimate(
      width: dimensions[:width].to_f.inches,
      height: dimensions[:height].to_f.inches,
      colors: colors,
      yarn: yarn
    )

    color_results = {}
    all_sufficient = true

    colors.each_key do |color_name|
      color_data = result[color_name]
      estimated = color_data[:yardage].to(:yards).value.round(1)
      available = entry_map[color_name].sum(&:total_yardage)
      sufficient = available >= estimated

      all_sufficient = false unless sufficient

      color_results[color_name] = {
        estimated_yardage: estimated,
        estimated_skeins: color_data[:skeins],
        available_yardage: available,
        sufficient: sufficient,
        surplus: sufficient ? (available - estimated).round(1) : 0,
        shortage: sufficient ? 0 : (estimated - available).round(1)
      }
    end

    total_estimated = result[:total][:yardage].to(:yards).value.round(1)

    {
      mode: "colorwork",
      technique: technique_sym.to_s,
      colors: color_results,
      total_estimated_yardage: total_estimated,
      all_sufficient: all_sufficient
    }
  end

  private

  def build_gauge(params)
    FiberGauge::Gauge.new(
      stitches: params[:stitches].to_f.stitches,
      rows: params[:rows].to_f.rows,
      width: params[:width].to_f.inches,
      height: (params[:height] || params[:width]).to_f.inches
    )
  end

  def build_yarn(entry)
    YarnSkein::Yarn.new(
      brand: entry.brand,
      line: entry.line,
      yardage: entry.yardage.yards,
      skein_weight: entry.skein_weight.grams
    )
  end

  def find_entries(ids)
    @user.stash_entries_dataset.where(id: Array(ids).map(&:to_i)).all
  end
end
