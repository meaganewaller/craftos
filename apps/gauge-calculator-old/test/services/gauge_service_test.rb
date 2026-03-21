require "test_helper"

class GaugeServiceTest < ActiveSupport::TestCase
  test "results returns spi and rpi from the gauge" do
    test_case = self
    fake_gauge = Struct.new(:spi, :rpi).new(5.0, 7.0)

    stub_class_method(FiberGauge::Gauge, :new, ->(**kwargs) {
      test_case.assert_instance_of FiberUnits::StitchCount, kwargs[:stitches]
      test_case.assert_equal 20, kwargs[:stitches].value
      test_case.assert_instance_of FiberUnits::RowCount, kwargs[:rows]
      test_case.assert_equal 28, kwargs[:rows].value
      test_case.assert_equal 4, kwargs[:width].value
      test_case.assert_equal :inches, kwargs[:width].unit

      fake_gauge
    }) do
      service = GaugeService.new(stitches: 20, rows: 28, width: 4)

      assert_equal({spi: 5.0, rpi: 7.0}, service.results)
    end
  end

  test "stitches_for returns the raw value from the gauge" do
    test_case = self
    fake_gauge = Object.new
    fake_gauge.define_singleton_method(:required_stitches) do |width|
      test_case.assert_equal 10, width.value
      test_case.assert_equal :inches, width.unit

      Struct.new(:value).new(50)
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      service = GaugeService.new(stitches: 20, rows: 28, width: 4)

      assert_equal 50, service.stitches_for(10)
    end
  end

  test "rows_for returns the raw value from the gauge" do
    test_case = self
    fake_gauge = Object.new
    fake_gauge.define_singleton_method(:required_rows) do |height|
      test_case.assert_equal 8, height.value
      test_case.assert_equal :inches, height.unit

      Struct.new(:value).new(56)
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      service = GaugeService.new(stitches: 20, rows: 28, width: 4)

      assert_equal 56, service.rows_for(8)
    end
  end
end
