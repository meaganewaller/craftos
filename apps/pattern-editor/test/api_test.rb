require "test_helper"

class PatternEditorApiTest < Minitest::Test
  def test_post_api_piece_returns_calculations
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25}
    }

    assert last_response.ok?
    data = json_response
    assert_equal 90, data["cast_on"]
    assert_equal 150, data["total_rows"]
    assert data.key?("finished_width")
    assert data.key?("finished_height")
  end

  def test_post_api_piece_with_stitch_pattern
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25},
      stitch_pattern: "rib_1x1"
    }

    assert last_response.ok?
    data = json_response
    # 1x1 rib has width_factor 0.90, so more stitches needed
    assert data["cast_on"] > 90
  end

  def test_post_api_piece_with_repeat
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25},
      repeat: {multiple: 4, offset: 2}
    }

    assert last_response.ok?
    data = json_response
    # Cast on should be adjusted to satisfy repeat: (multiple * n) + offset
    assert_equal 2, data["cast_on"] % 4
  end

  def test_post_api_piece_with_centimeters
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 10, unit: "centimeters"},
      piece: {width: 50, height: 60}
    }

    assert last_response.ok?
    data = json_response
    assert_equal 90, data["cast_on"]
    assert_equal 144, data["total_rows"]
  end

  def test_post_api_piece_returns_422_without_gauge
    post_json "/api/piece", {
      piece: {width: 20, height: 25}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "gauge"
  end

  def test_post_api_piece_returns_422_without_piece
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "piece"
  end

  def test_post_api_piece_returns_422_for_missing_gauge_params
    post_json "/api/piece", {
      gauge: {stitches: 18},
      piece: {width: 20, height: 25}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "rows"
  end

  def test_post_api_piece_returns_422_for_zero_gauge_value
    post_json "/api/piece", {
      gauge: {stitches: 0, rows: 24, width: 4},
      piece: {width: 20, height: 25}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "positive"
  end

  def test_post_api_piece_returns_422_for_missing_piece_params
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "height"
  end

  def test_post_api_piece_returns_422_for_zero_piece_value
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 0, height: 25}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "positive"
  end

  def test_get_api_stitch_patterns_returns_list
    request_get "/api/stitch_patterns"

    assert last_response.ok?
    patterns = json_response
    assert_kind_of Array, patterns
    assert patterns.length >= 10

    stockinette = patterns.find { |p| p["key"] == "stockinette" }
    assert_equal "Stockinette", stockinette["name"]
    assert_equal 1.0, stockinette["width_factor"]
    assert_equal 1.0, stockinette["yarn_factor"]
  end

  def test_get_api_stitch_patterns_includes_crochet
    request_get "/api/stitch_patterns"

    patterns = json_response
    keys = patterns.map { |p| p["key"] }
    assert_includes keys, "double_crochet"
    assert_includes keys, "shell_stitch"
  end

  def test_post_api_piece_ignores_unknown_stitch_pattern
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25},
      stitch_pattern: "nonexistent"
    }

    assert last_response.ok?
    assert_equal 90, json_response["cast_on"]
  end
end
