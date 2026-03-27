# frozen_string_literal: true

class PieceService
  STITCH_PATTERNS = {
    "stockinette" => :stockinette,
    "garter" => :garter,
    "rib_1x1" => :rib_1x1,
    "rib_2x2" => :rib_2x2,
    "seed" => :seed,
    "moss_stitch" => :moss_stitch,
    "single_crochet" => :single_crochet,
    "half_double_crochet" => :half_double_crochet,
    "double_crochet" => :double_crochet,
    "treble_crochet" => :treble_crochet,
    "shell_stitch" => :shell_stitch,
    "v_stitch" => :v_stitch
  }.freeze

  attr_reader :gauge, :sizing

  def initialize(gauge_params:, piece_params:, stitch_pattern_name: nil, repeat_params: nil, unit: nil, shaping_params: nil)
    @unit = unit || "inches"
    @gauge = build_gauge(gauge_params)
    @stitch_pattern = build_stitch_pattern(stitch_pattern_name)
    @repeat = build_repeat(repeat_params)
    @piece_width = piece_params.fetch("width").to_f.public_send(@unit)
    @piece_height = piece_params.fetch("height").to_f.public_send(@unit)
    @sizing = FiberPattern::Sizing.new(gauge: @gauge, repeat: @repeat, stitch_pattern: @stitch_pattern)
    @shaping_params = shaping_params
  end

  def cast_on
    @sizing.cast_on_for(@piece_width).value
  end

  def total_rows
    @gauge.required_rows(@piece_height).value
  end

  def finished_width
    width_in_inches = @gauge.width_for_stitches(cast_on.stitches)
    width_in_inches.to(@unit.to_sym).value.round(2)
  end

  def finished_height
    (total_rows.to_f / @gauge.rpi).round(2)
  end

  def shaping_results
    return {enabled: false} unless shaping_enabled?

    end_width = @shaping_params.fetch("end_width").to_f.public_send(@unit)
    end_stitches = @sizing.cast_on_for(end_width).value
    start_stitches = cast_on
    shaping_method = (end_stitches > start_stitches) ? :increase : :decrease

    shaping = FiberPattern::Shaping.new(
      from: start_stitches.stitches,
      to: end_stitches.stitches,
      over: total_rows.rows,
      method: shaping_method,
      stitches_per_event: (@shaping_params["stitches_per_event"] || 2).to_i
    )

    end_width_value = @gauge.width_for_stitches(end_stitches.stitches).to(@unit.to_sym).value.round(2)

    {
      enabled: true,
      method: shaping_method,
      end_stitches: end_stitches,
      end_width: end_width_value,
      total_changes: shaping.total_changes,
      every_n_rows: shaping.every_n_rows,
      schedule: shaping.schedule
    }
  end

  def results
    co = cast_on
    rows = total_rows
    {
      cast_on: co,
      total_rows: rows,
      finished_width: finished_width,
      finished_height: finished_height,
      shaping: shaping_results
    }
  end

  def self.stitch_pattern_list
    STITCH_PATTERNS.map do |key, method_name|
      pattern = FiberPattern::StitchPattern.public_send(method_name)
      {
        key: key,
        name: pattern.name,
        width_factor: pattern.width_factor,
        yarn_factor: pattern.yarn_factor
      }
    end
  end

  private

  def shaping_enabled?
    return false if @shaping_params.nil?

    end_width = @shaping_params["end_width"]
    return false if end_width.nil?

    end_width.to_f > 0 && end_width.to_f != @piece_width.value
  end

  def build_gauge(params)
    gauge_opts = {
      stitches: params.fetch("stitches").to_i.stitches,
      rows: params.fetch("rows").to_i.rows,
      width: params.fetch("width").to_f.public_send(@unit)
    }
    height = params["height"]
    gauge_opts[:height] = height.to_f.public_send(@unit) if height
    FiberGauge::Gauge.new(**gauge_opts)
  end

  def build_stitch_pattern(name)
    return nil if name.nil? || name.empty?
    method_name = STITCH_PATTERNS[name]
    return nil unless method_name
    FiberPattern::StitchPattern.public_send(method_name)
  end

  def build_repeat(params)
    return nil if params.nil?
    multiple = params["multiple"]&.to_i
    return nil if multiple.nil? || multiple <= 0
    offset = (params["offset"] || 0).to_i
    FiberPattern::Repeat.new(multiple: multiple.stitches, offset: offset.stitches)
  end
end
