# frozen_string_literal: true

require "test_helper"

class NumericDslExtensionsTest < Minitest::Test
  # -----------------------------
  # Length helpers
  # -----------------------------

  def test_creates_millimeters
    result = 5.millimeters

    assert_instance_of FiberUnits::Length, result
    assert_equal 5, result.value
    assert_equal :millimeters, result.unit
  end

  def test_creates_centimeters
    result = 3.centimeters

    assert_instance_of FiberUnits::Length, result
    assert_equal 3, result.value
    assert_equal :centimeters, result.unit
  end

  def test_creates_inches
    result = 4.inches

    assert_instance_of FiberUnits::Length, result
    assert_equal 4, result.value
    assert_equal :inches, result.unit
  end

  def test_creates_feet
    result = 2.feet

    assert_instance_of FiberUnits::Length, result
    assert_equal 2, result.value
    assert_equal :feet, result.unit
  end

  def test_creates_yards
    result = 7.yards

    assert_instance_of FiberUnits::Length, result
    assert_equal 7, result.value
    assert_equal :yards, result.unit
  end

  def test_creates_meters
    result = 1.meters

    assert_instance_of FiberUnits::Length, result
    assert_equal 1, result.value
    assert_equal :meters, result.unit
  end

  # -----------------------------
  # Weight helpers
  # -----------------------------

  def test_creates_grams
    result = 100.grams

    assert_instance_of FiberUnits::Weight, result
    assert_equal 100, result.value
    assert_equal :grams, result.unit
  end

  def test_creates_kilograms
    result = 2.kilograms

    assert_instance_of FiberUnits::Weight, result
    assert_equal 2, result.value
    assert_equal :kilograms, result.unit
  end

  def test_creates_ounces
    result = 8.ounces

    assert_instance_of FiberUnits::Weight, result
    assert_equal 8, result.value
    assert_equal :ounces, result.unit
  end

  def test_creates_pounds
    result = 1.pounds

    assert_instance_of FiberUnits::Weight, result
    assert_equal 1, result.value
    assert_equal :pounds, result.unit
  end

  # -----------------------------
  # Fiber counts
  # -----------------------------

  def test_creates_stitch_counts
    result = 20.stitches

    assert_instance_of FiberUnits::StitchCount, result
    assert_equal 20, result.value
  end

  def test_creates_row_counts
    result = 32.rows

    assert_instance_of FiberUnits::RowCount, result
    assert_equal 32, result.value
  end
end
