require "test_helper"

class GaugeControllerTest < ActionDispatch::IntegrationTest
  test "POST /gauge returns spi and rpi" do
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
      post "/gauge", params: { stitches: 20, rows: 28, width: 4 }
    end

    assert_response :success
    assert_equal({ "spi" => 5.0, "rpi" => 7.0 }, response.parsed_body)
  end

  test "POST /gauge/stitches returns required stitches using requested unit" do
    test_case = self
    fake_gauge = Object.new
    fake_stitches = Struct.new(:value).new(50)

    fake_gauge.define_singleton_method(:required_stitches) do |target_width|
      test_case.assert_equal 25.4, target_width.value
      test_case.assert_equal :centimeters, target_width.unit

      fake_stitches
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      post "/gauge/stitches", params: {
        stitches: 20,
        rows: 28,
        width: 4,
        target_width: 25.4,
        unit: "centimeters"
      }
    end

    assert_response :success
    assert_equal({ "stitches" => 50 }, response.parsed_body)
  end

  test "POST /gauge/rows returns required rows in default inches" do
    test_case = self
    fake_gauge = Object.new
    fake_rows = Struct.new(:value).new(56)

    fake_gauge.define_singleton_method(:required_rows) do |target_height|
      test_case.assert_equal 8.0, target_height.value
      test_case.assert_equal :inches, target_height.unit

      fake_rows
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      post "/gauge/rows", params: {
        stitches: 20,
        rows: 28,
        width: 4,
        target_height: 8
      }
    end

    assert_response :success
    assert_equal({ "rows" => 56 }, response.parsed_body)
  end
end
