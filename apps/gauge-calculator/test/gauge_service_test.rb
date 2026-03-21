require "test_helper"

class GaugeServiceTest < Minitest::Test
  def test_results_returns_spi_and_rpi_from_the_gauge
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
      service = GaugeService.new(stitches: 20, rows: 28, width: 4)

      assert_equal({spi: 5.0, rpi: 7.0}, service.results)
    end
  end

  def test_stitches_for_returns_the_raw_value_from_the_gauge
    test_case = self
    fake_gauge = Object.new
    fake_gauge.define_singleton_method(:required_stitches) do |width|
      test_case.assert_equal 10.0, width.value
      test_case.assert_equal :inches, width.unit

      Struct.new(:value).new(50)
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      service = GaugeService.new(stitches: 20, rows: 28, width: 4)

      assert_equal 50, service.stitches_for(10)
    end
  end

  def test_rpi_uses_height_when_provided
    call_count = 0
    width_gauge = Struct.new(:spi, :rpi).new(5.0, 7.0)
    height_gauge = Struct.new(:spi, :rpi).new(5.0, 6.0)

    stub_class_method(FiberGauge::Gauge, :new, ->(**kwargs) {
      call_count += 1
      if call_count == 1
        width_gauge
      else
        height_gauge
      end
    }) do
      service = GaugeService.new(stitches: 20, rows: 28, width: 4, height: 5)

      assert_equal 5.0, service.spi
      assert_equal 6.0, service.rpi
    end

    assert_equal 2, call_count
  end

  def test_rpi_uses_width_when_height_omitted
    fake_gauge = Struct.new(:spi, :rpi).new(5.0, 7.0)

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      service = GaugeService.new(stitches: 20, rows: 28, width: 4)

      assert_equal 5.0, service.spi
      assert_equal 7.0, service.rpi
    end
  end

  def test_rows_for_returns_the_raw_value_from_the_gauge
    test_case = self
    fake_gauge = Object.new
    fake_gauge.define_singleton_method(:required_rows) do |height|
      test_case.assert_equal 8.0, height.value
      test_case.assert_equal :inches, height.unit

      Struct.new(:value).new(56)
    end

    stub_class_method(FiberGauge::Gauge, :new, ->(**) { fake_gauge }) do
      service = GaugeService.new(stitches: 20, rows: 28, width: 4)

      assert_equal 56, service.rows_for(8)
    end
  end
end
