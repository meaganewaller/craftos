# frozen_string_literal: true

require "test_helper"

class FiberUnitsStitchCountTest < Minitest::Test
  def test_stores_stitch_value
    stitches = 20.stitches

    assert_equal 20, stitches.value
  end

  def test_adds_stitches
    result = 20.stitches + 10.stitches

    assert_equal 30, result.value
  end

  def test_subtracts_stitches
    result = 20.stitches - 5.stitches

    assert_equal 15.stitches, result
  end

  def test_multiplies_stitches_by_scalar
    result = 20.stitches * 2

    assert_equal 40.stitches, result
  end

  def test_converts_stitches_to_integer
    assert_equal 20, 20.stitches.to_i
  end

  def test_compares_stitch_counts_by_value
    assert 20.stitches > 10.stitches
    assert 20.stitches < 30.stitches
  end

  def test_stitches_not_equal_to_row_counts
    refute_equal 20.rows, 20.stitches
  end

  def test_spaceship_operator_returns_nil_for_different_count_type
    assert_nil(20.stitches <=> 20.rows)
  end

  def test_addition_with_different_count_type_raises
    error = assert_raises(FiberUnits::DimensionError) do
      20.stitches + 20.rows
    end

    assert_equal(
      "Cannot combine FiberUnits::StitchCount with FiberUnits::RowCount",
      error.message
    )
  end

  def test_subtraction_with_different_count_type_raises
    error = assert_raises(FiberUnits::DimensionError) do
      20.stitches - 20.rows
    end

    assert_equal(
      "Cannot combine FiberUnits::StitchCount with FiberUnits::RowCount",
      error.message
    )
  end

  def test_stitch_counts_equality
    assert_equal 20.stitches, 20.stitches
    refute_equal 20.stitches, 30.stitches
  end
end
