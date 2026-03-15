# frozen_string_literal: true

require "test_helper"

class FiberUnitsLengthTest < Minitest::Test
  # -----------------------------
  # Initialization
  # -----------------------------

  def test_initialization_stores_value_and_unit
    length = FiberUnits::Length.new(4, :inches)

    assert_equal 4, length.value
    assert_equal :inches, length.unit
  end

  # -----------------------------
  # Conversion
  # -----------------------------

  def test_converts_inches_to_centimeters
    result = 4.inches.to(:centimeters)

    assert_equal 10.16, result.value.round(2)
  end

  def test_converts_yards_to_meters
    result = 210.yards.to(:meters)

    assert_equal 192.024, result.value.round(3)
  end

  # -----------------------------
  # Comparison
  # -----------------------------

  def test_compares_equal_values_across_units
    assert_equal 100, 1.meters.to(:centimeters).value
  end

  # -----------------------------
  # to_base
  # -----------------------------

  def test_to_base_converts_inches_to_millimeters
    length = 4.inches

    assert_equal 101.6, length.to_base
  end

  def test_to_base_converts_yards_to_millimeters
    length = 1.yards

    assert_equal 914.4, length.to_base
  end

  def test_to_base_converts_meters_to_millimeters
    length = 2.meters

    assert_equal 2000, length.to_base
  end

  # -----------------------------
  # from_base
  # -----------------------------

  def test_from_base_creates_measurement
    result = FiberUnits::Length.from_base(25.4)

    assert_instance_of FiberUnits::Length, result
  end

  def test_from_base_uses_base_unit
    result = FiberUnits::Length.from_base(25.4)

    assert_equal :millimeters, result.unit
  end

  def test_from_base_returns_correct_value
    result = FiberUnits::Length.from_base(25.4)

    assert_equal 25.4, result.value
  end
end
