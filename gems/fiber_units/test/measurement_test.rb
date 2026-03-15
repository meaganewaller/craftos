# frozen_string_literal: true

require "test_helper"

class FiberUnitsMeasurementTest < Minitest::Test
  class MeasurementWithoutFactors < FiberUnits::Measurement; end

  class MeasurementWithoutBaseUnit < FiberUnits::Measurement
    FACTORS = {
      inches: 25.4,
      feet: 304.8
    }.freeze
  end

  # -----------------------------
  # Arithmetic
  # -----------------------------

  def test_adds_measurements_of_same_type
    result = 4.inches + 2.inches

    assert_equal 6, result.value
    assert_equal :inches, result.unit
  end

  def test_subtracts_measurements
    result = 10.inches - 4.inches

    assert_equal 6, result.value
  end

  def test_multiplies_by_scalar
    result = 4.inches * 3

    assert_equal 12, result.value
  end

  # -----------------------------
  # Division
  # -----------------------------

  def test_divides_measurement_values
    result = 10.inches / 2

    assert_equal 5, result.value
  end

  def test_division_preserves_measurement_class
    result = 10.inches / 2

    assert_instance_of FiberUnits::Length, result
  end

  def test_division_preserves_unit
    result = 10.inches / 2

    assert_equal :inches, result.unit
  end

  # -----------------------------
  # Ratios
  # -----------------------------

  def test_creates_ratio_objects
    ratio = 210.yards / 100.grams

    assert_instance_of FiberUnits::Ratio, ratio
  end

  # -----------------------------
  # Dimension Safety
  # -----------------------------

  def test_addition_with_incompatible_dimensions_raises
    assert_raises(FiberUnits::DimensionError) do
      4.inches + 100.grams
    end
  end

  def test_subtraction_with_incompatible_dimensions_raises
    assert_raises(FiberUnits::DimensionError) do
      4.inches - 2.grams
    end
  end

  def test_dimension_error_contains_helpful_message
    error = assert_raises(FiberUnits::DimensionError) do
      4.inches + 100.grams
    end

    assert_match(
      /Cannot combine FiberUnits::Length with FiberUnits::Weight/,
      error.message
    )
  end

  # -----------------------------
  # Comparison Operators
  # -----------------------------

  def test_greater_than
    left = 4.inches
    right = 4.inches

    assert 4.inches > 2.inches
    refute 2.inches > 4.inches
    refute left > right
    assert 4.inches > 10.centimeters
  end

  def test_less_than
    left = 4.inches
    right = 4.inches

    assert 2.inches < 4.inches
    refute 4.inches < 2.inches
    refute left < right
    assert 10.centimeters < 4.inches
  end

  def test_greater_than_or_equal
    left = 4.inches
    right = 4.inches

    assert 4.inches >= 2.inches
    assert left >= right
    refute 2.inches >= 4.inches
    assert 4.inches >= 10.centimeters
  end

  def test_less_than_or_equal
    left = 4.inches
    right = 4.inches

    assert 2.inches <= 4.inches
    assert left <= right
    refute 4.inches <= 2.inches
    assert 10.centimeters <= 4.inches
  end

  def test_equality
    left = 4.inches
    right = 4.inches

    assert left == right
    refute left == 2.inches
    assert 1.yards == 36.inches

    result = 1.yards + 0.inches
    assert result == 1.yards
  end

  def test_equality_returns_false_for_non_measurement
    refute 4.inches == 4
  end

  def test_equality_returns_false_for_different_measurement_type
    refute 4.inches == 4.grams
  end

  def test_inequality
    left = 4.inches
    right = 4.inches

    refute left != right
    assert 4.inches != 2.inches
    refute 1.yards != 36.inches
  end

  # -----------------------------
  # Comparison Dimension Safety
  # -----------------------------

  def test_greater_than_with_incompatible_dimensions_raises
    assert_raises(FiberUnits::DimensionError) do
      4.inches > 100.grams
    end
  end

  def test_less_than_with_incompatible_dimensions_raises
    assert_raises(FiberUnits::DimensionError) do
      4.inches < 100.grams
    end
  end

  def test_greater_than_or_equal_with_incompatible_dimensions_raises
    assert_raises(FiberUnits::DimensionError) do
      4.inches >= 100.grams
    end
  end

  def test_less_than_or_equal_with_incompatible_dimensions_raises
    assert_raises(FiberUnits::DimensionError) do
      4.inches <= 100.grams
    end
  end

  # -----------------------------
  # Conversion Guards
  # -----------------------------

  def test_conversion_to_invalid_unit_raises
    assert_raises(FiberUnits::InvalidUnitError) do
      4.inches.to(:bananas)
    end
  end

  def test_to_base_raises_without_factors
    measurement = MeasurementWithoutFactors.new(4, :inches)

    assert_raises(NotImplementedError) do
      measurement.to_base
    end
  end

  def test_from_base_raises_without_base_unit
    assert_raises(FiberUnits::InvalidUnitError) do
      MeasurementWithoutBaseUnit.from_base(25.4)
    end
  end
end
