# frozen_string_literal: true

require "test_helper"

class FiberUnitsWeightConversionTest < Minitest::Test
  def test_converts_grams_to_ounces
    result = FiberUnits::Conversions::WeightConversion.convert(100, :grams, :ounces)

    assert_equal 3.527, result.round(3)
  end

  def test_converts_pounds_to_kilograms
    result = FiberUnits::Conversions::WeightConversion.convert(1, :pounds, :kilograms)

    assert_equal 0.4536, result.round(4)
  end

  def test_raises_error_for_invalid_unit
    assert_raises(FiberUnits::InvalidUnitError) do
      FiberUnits::Conversions::WeightConversion.convert(1, :rocks, :grams)
    end
  end

  def test_raises_error_for_invalid_target_unit
    assert_raises(FiberUnits::InvalidUnitError) do
      FiberUnits::Conversions::WeightConversion.convert(1, :grams, :rocks)
    end
  end
end
