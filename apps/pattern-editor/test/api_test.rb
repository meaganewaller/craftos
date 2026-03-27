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

  # ----- shaping -----

  def test_post_api_piece_with_shaping_decrease
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25},
      shaping: {end_width: 14}
    }

    assert last_response.ok?
    data = json_response
    shaping = data["shaping"]
    assert shaping["enabled"]
    assert_equal "decrease", shaping["method"]
    assert_equal 63, shaping["end_stitches"]
    assert_equal 14.0, shaping["end_width"]
    assert shaping["total_changes"] > 0
    assert_kind_of Array, shaping["schedule"]
  end

  def test_post_api_piece_with_shaping_increase
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25},
      shaping: {end_width: 26}
    }

    assert last_response.ok?
    assert_equal "increase", json_response["shaping"]["method"]
  end

  def test_post_api_piece_without_shaping_returns_disabled
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25}
    }

    assert last_response.ok?
    refute json_response["shaping"]["enabled"]
  end

  def test_post_api_piece_returns_422_for_shaping_missing_end_width
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25},
      shaping: {}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "end_width"
  end

  def test_post_api_piece_returns_422_for_negative_end_width
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25},
      shaping: {end_width: -5}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "positive"
  end

  def test_post_api_piece_returns_422_for_zero_stitches_per_event
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25},
      shaping: {end_width: 14, stitches_per_event: 0}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "stitches_per_event"
  end

  # ----- POST /api/project -----

  def test_post_api_project_returns_all_pieces
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      stitch_pattern: "stockinette",
      pieces: [
        {name: "Back", width: 20, height: 25},
        {name: "Front", width: 20, height: 25, shaping: {end_width: 16}},
        {name: "Sleeve", width: 10, height: 18, shaping: {end_width: 16}}
      ]
    }

    assert last_response.ok?
    data = json_response
    assert_equal 3, data["pieces"].length

    back = data["pieces"][0]
    assert_equal "Back", back["name"]
    assert_equal 90, back["cast_on"]
    assert_equal 150, back["total_rows"]
    refute back["shaping"]["enabled"]

    front = data["pieces"][1]
    assert_equal "Front", front["name"]
    assert front["shaping"]["enabled"]
    assert_equal "decrease", front["shaping"]["method"]

    sleeve = data["pieces"][2]
    assert_equal "Sleeve", sleeve["name"]
    assert sleeve["shaping"]["enabled"]
    assert_equal "increase", sleeve["shaping"]["method"]
  end

  def test_post_api_project_shared_gauge_applies_to_all
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      pieces: [
        {name: "A", width: 20, height: 25},
        {name: "B", width: 10, height: 12}
      ]
    }

    assert last_response.ok?
    pieces = json_response["pieces"]
    assert_equal 90, pieces[0]["cast_on"]
    assert_equal 150, pieces[0]["total_rows"]
    assert_equal 45, pieces[1]["cast_on"]
    assert_equal 72, pieces[1]["total_rows"]
  end

  def test_post_api_project_with_repeat
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      repeat: {multiple: 4, offset: 2},
      pieces: [
        {name: "Panel", width: 20, height: 25}
      ]
    }

    assert last_response.ok?
    assert_equal 2, json_response["pieces"][0]["cast_on"] % 4
  end

  def test_post_api_project_returns_422_without_pieces
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4}
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "pieces"
  end

  def test_post_api_project_returns_422_for_empty_pieces
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      pieces: []
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "empty"
  end

  def test_post_api_project_returns_422_for_piece_missing_name
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      pieces: [{width: 20, height: 25}]
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "name"
  end

  def test_post_api_project_returns_422_for_piece_with_empty_name
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      pieces: [{name: "  ", width: 20, height: 25}]
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "name"
  end

  def test_post_api_project_returns_422_for_piece_missing_width
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      pieces: [{name: "Back", height: 25}]
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "width"
  end

  def test_post_api_project_returns_422_for_piece_missing_height
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      pieces: [{name: "Back", width: 20}]
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "height"
  end

  def test_post_api_project_returns_422_for_piece_zero_width
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      pieces: [{name: "Back", width: 0, height: 25}]
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "positive"
  end

  def test_post_api_project_returns_422_without_gauge
    post_json "/api/project", {
      pieces: [{name: "Back", width: 20, height: 25}]
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "gauge"
  end

  def test_post_api_project_validates_per_piece_shaping
    post_json "/api/project", {
      gauge: {stitches: 18, rows: 24, width: 4},
      pieces: [{name: "Front", width: 20, height: 25, shaping: {}}]
    }

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "end_width"
  end

  def test_existing_piece_endpoint_still_works
    post_json "/api/piece", {
      gauge: {stitches: 18, rows: 24, width: 4},
      piece: {width: 20, height: 25}
    }

    assert last_response.ok?
    assert_equal 90, json_response["cast_on"]
  end
end
