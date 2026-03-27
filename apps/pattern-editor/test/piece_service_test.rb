require "test_helper"

class PieceServiceTest < Minitest::Test
  def default_gauge_params
    {"stitches" => 18, "rows" => 24, "width" => 4}
  end

  def default_piece_params
    {"width" => 20, "height" => 25}
  end

  def build_service(**overrides)
    PieceService.new(
      gauge_params: overrides.fetch(:gauge_params, default_gauge_params),
      piece_params: overrides.fetch(:piece_params, default_piece_params),
      stitch_pattern_name: overrides[:stitch_pattern_name],
      repeat_params: overrides[:repeat_params],
      unit: overrides[:unit],
      shaping_params: overrides[:shaping_params]
    )
  end

  def test_cast_on_for_basic_piece
    service = build_service
    # 18 stitches / 4 inches = 4.5 SPI, 20 inches * 4.5 = 90 stitches
    assert_equal 90, service.cast_on
  end

  def test_total_rows_for_basic_piece
    service = build_service
    # 24 rows / 4 inches = 6 RPI, 25 inches * 6 = 150 rows
    assert_equal 150, service.total_rows
  end

  def test_finished_width
    service = build_service
    # 90 stitches / 4.5 SPI = 20.0 inches
    assert_equal 20.0, service.finished_width
  end

  def test_finished_height
    service = build_service
    # 150 rows / 6.0 RPI = 25.0
    assert_equal 25.0, service.finished_height
  end

  def test_results_returns_all_fields
    service = build_service
    results = service.results
    assert_equal 90, results[:cast_on]
    assert_equal 150, results[:total_rows]
    assert results.key?(:finished_width)
    assert results.key?(:finished_height)
  end

  def test_with_stitch_pattern_adjusts_cast_on
    service = build_service(stitch_pattern_name: "rib_1x1")
    # 1x1 rib has width_factor 0.90, so needs more stitches
    assert service.cast_on > 90
  end

  def test_with_repeat_adjusts_cast_on
    service = build_service(repeat_params: {"multiple" => 4, "offset" => 2})
    # Should be (4 * n) + 2
    assert_equal 2, service.cast_on % 4
  end

  def test_with_centimeters
    service = build_service(
      gauge_params: {"stitches" => 18, "rows" => 24, "width" => 10},
      piece_params: {"width" => 50, "height" => 60},
      unit: "centimeters"
    )
    assert_equal 90, service.cast_on
    assert_equal 144, service.total_rows
  end

  def test_unknown_stitch_pattern_is_ignored
    service = build_service(stitch_pattern_name: "nonexistent")
    assert_equal 90, service.cast_on
  end

  def test_nil_repeat_params_ignored
    service = build_service(repeat_params: nil)
    assert_equal 90, service.cast_on
  end

  def test_zero_repeat_multiple_ignored
    service = build_service(repeat_params: {"multiple" => 0})
    assert_equal 90, service.cast_on
  end

  def test_stitch_pattern_list_returns_all_patterns
    list = PieceService.stitch_pattern_list
    assert_kind_of Array, list
    assert list.length >= 10

    keys = list.map { |p| p[:key] }
    assert_includes keys, "stockinette"
    assert_includes keys, "rib_1x1"
    assert_includes keys, "double_crochet"
  end

  def test_stitch_pattern_list_entries_have_required_fields
    entry = PieceService.stitch_pattern_list.first
    assert entry.key?(:key)
    assert entry.key?(:name)
    assert entry.key?(:width_factor)
    assert entry.key?(:yarn_factor)
  end

  # ----- shaping -----

  def test_shaping_disabled_when_no_shaping_params
    service = build_service
    assert_equal({enabled: false}, service.shaping_results)
  end

  def test_shaping_disabled_when_end_width_equals_piece_width
    service = build_service(shaping_params: {"end_width" => 20})
    assert_equal({enabled: false}, service.shaping_results)
  end

  def test_shaping_decrease
    # piece is 20" wide, shaping down to 14"
    service = build_service(shaping_params: {"end_width" => 14})
    result = service.shaping_results

    assert result[:enabled]
    assert_equal :decrease, result[:method]
    assert_equal 63, result[:end_stitches]  # 14 * 4.5 = 63
    assert_equal 14.0, result[:end_width]
    assert result[:total_changes] > 0
    assert result[:every_n_rows] > 0
    assert_kind_of Array, result[:schedule]
    assert(result[:schedule].all? { |e| e[:action] == :dec })
  end

  def test_shaping_increase
    # piece is 20" wide, shaping up to 26"
    service = build_service(shaping_params: {"end_width" => 26})
    result = service.shaping_results

    assert result[:enabled]
    assert_equal :increase, result[:method]
    assert_equal 117, result[:end_stitches]  # 26 * 4.5 = 117
    assert(result[:schedule].all? { |e| e[:action] == :inc })
  end

  def test_shaping_with_custom_stitches_per_event
    service = build_service(shaping_params: {"end_width" => 14, "stitches_per_event" => 4})
    result = service.shaping_results

    assert result[:enabled]
    # With 4 stitches per event, fewer total changes needed
    default_service = build_service(shaping_params: {"end_width" => 14})
    assert result[:total_changes] < default_service.shaping_results[:total_changes]
  end

  def test_shaping_included_in_results
    service = build_service(shaping_params: {"end_width" => 14})
    results = service.results

    assert results.key?(:shaping)
    assert results[:shaping][:enabled]
  end

  def test_results_include_shaping_disabled_without_params
    service = build_service
    results = service.results

    assert results.key?(:shaping)
    refute results[:shaping][:enabled]
  end

  def test_shaping_with_centimeters
    service = build_service(
      gauge_params: {"stitches" => 18, "rows" => 24, "width" => 10},
      piece_params: {"width" => 50, "height" => 60},
      shaping_params: {"end_width" => 35},
      unit: "centimeters"
    )
    result = service.shaping_results

    assert result[:enabled]
    assert_equal :decrease, result[:method]
    assert result[:end_stitches] < 90  # less than cast on of 90
  end
end
