# frozen_string_literal: true

require "test_helper"

class StashManagerApiTest < Minitest::Test
  def setup
    super
    @user = create_and_login
  end

  def post_stash(body)
    request_post "/api/stash",
      JSON.generate(body),
      {"CONTENT_TYPE" => "application/json"}
  end

  def create_entry(attrs = {})
    defaults = {brand: "Malabrigo", line: "Rios", yardage: 210, skein_weight: 100, quantity: 3}
    post_stash(defaults.merge(attrs))
  end

  # -----------------------------
  # POST /api/stash
  # -----------------------------

  def test_creates_stash_entry
    create_entry

    assert_equal 201, last_response.status
    data = json_response
    assert_equal "Malabrigo", data["brand"]
    assert_equal "Rios", data["line"]
    assert_equal 210.0, data["yardage"]
    assert_equal 3, data["quantity"]
    assert_equal 630.0, data["total_yardage"]
  end

  def test_creates_entry_with_colorway
    create_entry(colorway: "Azul Profundo")

    assert_equal 201, last_response.status
    assert_equal "Azul Profundo", json_response["colorway"]
  end

  def test_defaults_quantity_to_1
    post_stash({brand: "Test", line: "Yarn", yardage: 100, skein_weight: 50})

    assert_equal 201, last_response.status
    assert_equal 1, json_response["quantity"]
  end

  def test_rejects_missing_brand
    post_stash({line: "Rios", yardage: 210, skein_weight: 100})

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "brand"
  end

  def test_rejects_non_positive_yardage
    post_stash({brand: "Test", line: "Yarn", yardage: 0, skein_weight: 100})

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "positive"
  end

  # -----------------------------
  # GET /api/stash
  # -----------------------------

  def test_lists_stash_entries
    create_entry
    create_entry(brand: "Cascade", line: "220")

    request_get "/api/stash"

    assert last_response.ok?
    entries = json_response
    assert_equal 2, entries.length
  end

  def test_lists_empty_stash
    request_get "/api/stash"

    assert last_response.ok?
    assert_equal [], json_response
  end

  def test_searches_by_brand
    create_entry(brand: "Malabrigo", line: "Rios")
    create_entry(brand: "Cascade", line: "220")

    request_get "/api/stash?search=Malabrigo"

    assert last_response.ok?
    entries = json_response
    assert_equal 1, entries.length
    assert_equal "Malabrigo", entries.first["brand"]
  end

  # -----------------------------
  # DELETE /api/stash/:id
  # -----------------------------

  def test_deletes_stash_entry
    create_entry
    id = json_response["id"]

    request_delete "/api/stash/#{id}"

    assert last_response.ok?
    assert json_response["deleted"]
  end

  def test_returns_404_for_missing_entry
    request_delete "/api/stash/9999"

    assert_equal 404, last_response.status
  end

  # -----------------------------
  # GET /api/stash/check
  # -----------------------------

  def test_check_yardage_sufficient
    create_entry(yardage: 210, quantity: 3)

    request_get "/api/stash/check?yardage=500"

    assert last_response.ok?
    data = json_response
    assert data["sufficient"]
    assert_equal 630.0, data["available"]
    assert_equal 0, data["shortage"]
  end

  def test_check_yardage_insufficient
    create_entry(yardage: 210, quantity: 1)

    request_get "/api/stash/check?yardage=500"

    assert last_response.ok?
    data = json_response
    refute data["sufficient"]
    assert_equal 290.0, data["shortage"]
  end

  def test_check_yardage_requires_positive_value
    request_get "/api/stash/check?yardage=0"

    assert_equal 422, last_response.status
  end

  def test_check_yardage_for_specific_yarn
    create_entry(yardage: 210, quantity: 3)
    id = json_response["id"]
    create_entry(brand: "Other", line: "Yarn", yardage: 100, quantity: 1)

    request_get "/api/stash/check?yardage=500&yarn_id=#{id}"

    assert last_response.ok?
    data = json_response
    assert data["sufficient"]
    assert_equal 630.0, data["available"]
  end

  # -----------------------------
  # POST /api/stash/project-check
  # -----------------------------

  def post_project_check(body)
    request_post "/api/stash/project-check",
      JSON.generate(body),
      {"CONTENT_TYPE" => "application/json"}
  end

  def test_project_check_simple_mode
    create_entry(yardage: 210, quantity: 10)
    id = json_response["id"]

    post_project_check(
      mode: "simple",
      gauge: {stitches: 18, rows: 24, width: 4, height: 4},
      dimensions: {width: 20, height: 20},
      stash_entry_ids: [id]
    )

    assert last_response.ok?
    data = json_response
    assert_equal "simple", data["mode"]
    assert data["estimated_yardage"] > 0
    assert_equal 2100.0, data["available_yardage"]
    assert data["sufficient"]
  end

  def test_project_check_colorwork_mode
    create_entry(yardage: 210, quantity: 10, colorway: "Navy")
    main_id = json_response["id"]
    create_entry(yardage: 210, quantity: 10, colorway: "Cream")
    contrast_id = json_response["id"]

    post_project_check(
      mode: "colorwork",
      gauge: {stitches: 18, rows: 24, width: 4, height: 4},
      dimensions: {width: 20, height: 20},
      technique: "stranded",
      colors: {
        main: {proportion: 0.6, stash_entry_ids: [main_id]},
        contrast: {proportion: 0.4, stash_entry_ids: [contrast_id]}
      }
    )

    assert last_response.ok?
    data = json_response
    assert_equal "colorwork", data["mode"]
    assert_equal "stranded", data["technique"]
    assert data["colors"]["main"]
    assert data["colors"]["contrast"]
    assert data["total_estimated_yardage"] > 0
  end

  def test_project_check_rejects_invalid_mode
    post_project_check(mode: "invalid", gauge: {stitches: 18, rows: 24, width: 4}, dimensions: {width: 20, height: 20})

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "mode"
  end

  def test_project_check_rejects_missing_gauge
    post_project_check(mode: "simple", dimensions: {width: 20, height: 20}, stash_entry_ids: [1])

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "gauge"
  end

  def test_project_check_rejects_missing_dimensions
    post_project_check(mode: "simple", gauge: {stitches: 18, rows: 24, width: 4}, stash_entry_ids: [1])

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "dimensions"
  end

  def test_project_check_rejects_missing_stash_entry_ids
    post_project_check(
      mode: "simple",
      gauge: {stitches: 18, rows: 24, width: 4, height: 4},
      dimensions: {width: 20, height: 20}
    )

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "stash_entry_ids"
  end

  def test_project_check_rejects_missing_technique
    post_project_check(
      mode: "colorwork",
      gauge: {stitches: 18, rows: 24, width: 4, height: 4},
      dimensions: {width: 20, height: 20},
      colors: {main: {proportion: 1.0, stash_entry_ids: [1]}}
    )

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "technique"
  end
end
