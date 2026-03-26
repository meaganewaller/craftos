# frozen_string_literal: true

require "test_helper"

class YarnSubstitutionApiTest < Minitest::Test
  def post_substitute(body)
    request_post "/api/substitute",
      JSON.generate(body),
      {"CONTENT_TYPE" => "application/json"}
  end

  # -----------------------------
  # validation
  # -----------------------------

  def test_returns_error_when_yardage_missing
    post_substitute({skein_weight: 100})

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "yardage"
  end

  def test_returns_error_when_skein_weight_missing
    post_substitute({yardage: 210})

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "skein_weight"
  end

  def test_returns_error_when_values_not_positive
    post_substitute({yardage: 0, skein_weight: 100})

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "positive"
  end

  # -----------------------------
  # successful requests
  # -----------------------------

  def test_returns_target_info
    post_substitute({yardage: 210, skein_weight: 100})

    assert last_response.ok?
    target = json_response["target"]
    assert_equal "worsted", target["weight_category"]
    assert_equal 210.0, target["yards_per_100g"]
  end

  def test_returns_matches_array
    post_substitute({yardage: 210, skein_weight: 100})

    assert last_response.ok?
    matches = json_response["matches"]
    assert_instance_of Array, matches
    assert matches.length > 0

    match = matches.first
    assert match.key?("brand")
    assert match.key?("line")
    assert match.key?("weight_category")
    assert match.key?("yards_per_100g")
  end

  def test_filters_by_fiber
    post_substitute({yardage: 210, skein_weight: 100, fiber: "cotton"})

    assert last_response.ok?
    matches = json_response["matches"]
    matches.each do |m|
      assert m["fiber_content"].key?("cotton"), "Expected #{m["brand"]} #{m["line"]} to contain cotton"
    end
  end

  def test_respects_tolerance
    # With very tight tolerance, fewer matches
    post_substitute({yardage: 210, skein_weight: 100, tolerance: 0.01})

    assert last_response.ok?
    tight_count = json_response["matches"].length

    post_substitute({yardage: 210, skein_weight: 100, tolerance: 0.25})

    assert last_response.ok?
    loose_count = json_response["matches"].length

    assert loose_count >= tight_count
  end

  def test_returns_empty_matches_when_no_substitutes_found
    # Super bulky range — few catalog entries match
    post_substitute({yardage: 30, skein_weight: 100, tolerance: 0.01})

    assert last_response.ok?
    assert_instance_of Array, json_response["matches"]
  end

  def test_accepts_optional_brand_and_line
    post_substitute({yardage: 210, skein_weight: 100, brand: "Test", line: "Yarn"})

    assert last_response.ok?
  end

  def test_matches_include_grist
    post_substitute({yardage: 210, skein_weight: 100})

    assert last_response.ok?
    match = json_response["matches"].first
    assert match.key?("grist"), "Expected match to include grist"
  end

  def test_target_includes_fiber_content_when_provided
    post_substitute({
      yardage: 210,
      skein_weight: 100,
      fiber_content: {wool: 80, nylon: 20}
    })

    assert last_response.ok?
    target = json_response["target"]
    assert target.key?("fiber_content")
    assert_equal 80, target["fiber_content"]["wool"]
  end

  def test_accepts_fiber_content_on_target
    post_substitute({
      yardage: 210,
      skein_weight: 100,
      fiber_content: {wool: 80, nylon: 20}
    })

    assert last_response.ok?
  end
end
