require "test_helper"

class GaugeCalculatorApiTest < Minitest::Test
  def json_response
    JSON.parse(last_response.body)
  end

  def test_post_api_gauge_returns_spi_and_rpi
    test_case = self
    fake_gauge = Struct.new(:spi, :rpi).new(5.0, 7.0)

    stub_class_method(FiberGauge::Gauge, :new, ->(**kwargs) {
      test_case.assert_instance_of FiberUnits::StitchCount, kwargs[:stitches]
      test_case.assert_equal 20, kwargs[:stitches].value
      test_case.assert_instance_of FiberUnits::RowCount, kwargs[:rows]
      test_case.assert_equal 28, kwargs[:rows].value
      test_case.assert_equal 4.0, kwargs[:width].value
      test_case.assert_equal :inches, kwargs[:width].unit

      fake_gauge
    }) do
      request_post "/api/gauge",
        JSON.generate({stitches: 20, rows: 28, width: 4}),
        {"CONTENT_TYPE" => "application/json"}
    end

    assert last_response.ok?
    assert_equal({"spi" => 5.0, "rpi" => 7.0}, json_response)
  end

  def test_post_api_gauge_uses_separate_height_for_rpi
    test_case = self
    fake_gauge = Struct.new(:spi, :rpi).new(5.0, 5.6)

    stub_class_method(FiberGauge::Gauge, :new, ->(**kwargs) {
      test_case.assert_equal 4.0, kwargs[:width].value
      test_case.assert_equal 5.0, kwargs[:height].value
      fake_gauge
    }) do
      request_post "/api/gauge",
        JSON.generate({stitches: 20, rows: 28, width: 4, height: 5}),
        {"CONTENT_TYPE" => "application/json"}
    end

    assert last_response.ok?
    assert_equal({"spi" => 5.0, "rpi" => 5.6}, json_response)
  end

  def test_post_api_gauge_stitches_returns_required_stitches_using_requested_unit
    test_case = self
    fake_gauge = Object.new
    fake_stitches = Struct.new(:value).new(50)

    fake_gauge.define_singleton_method(:required_stitches) do |target_width|
      test_case.assert_equal 25.4, target_width.value
      test_case.assert_equal :centimeters, target_width.unit

      fake_stitches
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      request_post "/api/gauge/stitches",
        JSON.generate({
          stitches: 20,
          rows: 28,
          width: 4,
          target_width: 25.4,
          unit: "centimeters"
        }),
        {"CONTENT_TYPE" => "application/json"}
    end

    assert last_response.ok?
    assert_equal({"stitches" => 50}, json_response)
  end

  def test_post_api_gauge_stitches_adjusts_for_pattern_repeat
    fake_gauge = Object.new
    fake_stitches = Struct.new(:value).new(191)

    fake_gauge.define_singleton_method(:required_stitches) { |_| fake_stitches }

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      request_post "/api/gauge/stitches",
        JSON.generate({
          stitches: 20,
          rows: 28,
          width: 4,
          target_width: 38,
          repeat: 4,
          offset: 2
        }),
        {"CONTENT_TYPE" => "application/json"}
    end

    assert last_response.ok?
    assert_equal 194, json_response["stitches"]
    assert_equal 191, json_response["base_stitches"]
  end

  def test_post_api_gauge_stitches_omits_base_when_no_repeat
    fake_gauge = Object.new
    fake_stitches = Struct.new(:value).new(190)

    fake_gauge.define_singleton_method(:required_stitches) { |_| fake_stitches }

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      request_post "/api/gauge/stitches",
        JSON.generate({
          stitches: 20,
          rows: 28,
          width: 4,
          target_width: 38
        }),
        {"CONTENT_TYPE" => "application/json"}
    end

    assert last_response.ok?
    assert_equal({"stitches" => 190}, json_response)
  end

  def test_post_api_gauge_rows_returns_required_rows_in_default_inches
    test_case = self
    fake_gauge = Object.new
    fake_rows = Struct.new(:value).new(56)

    fake_gauge.define_singleton_method(:required_rows) do |target_height|
      test_case.assert_equal 8.0, target_height.value
      test_case.assert_equal :inches, target_height.unit

      fake_rows
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      request_post "/api/gauge/rows",
        JSON.generate({
          stitches: 20,
          rows: 28,
          width: 4,
          target_height: 8
        }),
        {"CONTENT_TYPE" => "application/json"}
    end

    assert last_response.ok?
    assert_equal({"rows" => 56}, json_response)
  end

  def test_post_api_gauge_rows_uses_the_requested_unit
    test_case = self
    fake_gauge = Object.new
    fake_rows = Struct.new(:value).new(70)

    fake_gauge.define_singleton_method(:required_rows) do |target_height|
      test_case.assert_equal 25.4, target_height.value
      test_case.assert_equal :centimeters, target_height.unit

      fake_rows
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      request_post "/api/gauge/rows",
        JSON.generate({
          stitches: 20,
          rows: 28,
          width: 4,
          target_height: 25.4,
          unit: "centimeters"
        }),
        {"CONTENT_TYPE" => "application/json"}
    end

    assert last_response.ok?
    assert_equal({"rows" => 70}, json_response)
  end

  def test_post_api_gauge_returns_422_when_missing_required_params
    request_post "/api/gauge",
      JSON.generate({stitches: 20}),
      {"CONTENT_TYPE" => "application/json"}

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "rows"
    assert_includes json_response["error"], "width"
  end

  def test_post_api_gauge_returns_422_when_params_are_zero
    request_post "/api/gauge",
      JSON.generate({stitches: 0, rows: 28, width: 4}),
      {"CONTENT_TYPE" => "application/json"}

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "stitches"
  end

  def test_post_api_gauge_stitches_returns_422_when_missing_target_width
    request_post "/api/gauge/stitches",
      JSON.generate({stitches: 20, rows: 28, width: 4}),
      {"CONTENT_TYPE" => "application/json"}

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "target_width"
  end

  def test_post_api_gauge_rows_returns_422_when_missing_target_height
    request_post "/api/gauge/rows",
      JSON.generate({stitches: 20, rows: 28, width: 4}),
      {"CONTENT_TYPE" => "application/json"}

    assert_equal 422, last_response.status
    assert_includes json_response["error"], "target_height"
  end
end
