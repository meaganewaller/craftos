# frozen_string_literal: true

require "test_helper"

class FiberUnitsLengthConversionTest < Minitest::Test
  def test_converts_yards_to_meters
    result = FiberUnits::Conversions::LengthConversion.convert(210, :yards, :meters)

    assert_equal 192.024, result.round(3)
  end

  def test_converts_feet_to_centimeters
    result = FiberUnits::Conversions::LengthConversion.convert(1, :feet, :centimeters)

    assert_equal 30.48, result.round(2)
  end

  def test_raises_error_for_invalid_unit
    assert_raises(FiberUnits::InvalidUnitError) do
      FiberUnits::Conversions::LengthConversion.convert(1, :bananas, :meters)
    end
  end

  def test_raises_error_for_invalid_target_unit
    assert_raises(FiberUnits::InvalidUnitError) do
      FiberUnits::Conversions::LengthConversion.convert(1, :meters, :bananas)
    end
  end
end
