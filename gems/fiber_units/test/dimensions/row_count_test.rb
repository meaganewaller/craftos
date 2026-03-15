# frozen_string_literal: true

require "test_helper"

class FiberUnitsRowCountTest < Minitest::Test
  def test_stores_row_value
    rows = 24.rows

    assert_equal 24, rows.value
  end

  def test_adds_rows
    result = 24.rows + 6.rows

    assert_equal 30, result.value
  end

  def test_subtracts_rows
    result = 24.rows - 6.rows

    assert_equal 18.rows, result
  end

  def test_multiplies_rows_by_scalar
    result = 12.rows * 3

    assert_equal 36.rows, result
  end

  def test_converts_rows_to_integer
    assert_equal 24, 24.rows.to_i
  end

  def test_compares_row_counts_by_value
    assert 24.rows > 12.rows
    assert 24.rows < 30.rows
  end

  def test_rows_not_equal_to_stitch_counts
    refute_equal 24.stitches, 24.rows
  end

  def test_spaceship_operator_returns_nil_for_different_count_type
    assert_nil(24.rows <=> 24.stitches)
  end

  def test_addition_with_different_count_type_raises
    error = assert_raises(FiberUnits::DimensionError) do
      24.rows + 24.stitches
    end

    assert_equal(
      "Cannot combine FiberUnits::RowCount with FiberUnits::StitchCount",
      error.message
    )
  end

  def test_subtraction_with_different_count_type_raises
    error = assert_raises(FiberUnits::DimensionError) do
      24.rows - 24.stitches
    end

    assert_equal(
      "Cannot combine FiberUnits::RowCount with FiberUnits::StitchCount",
      error.message
    )
  end

  def test_row_counts_equality
    assert_equal 24.rows, 24.rows
    refute_equal 24.rows, 30.rows
  end

  def test_spaceship_operator_with_same_type
    left = 24.rows
    right = 24.rows

    assert_equal 0, (left <=> right)
    assert_equal 1, (24.rows <=> 12.rows)
    assert_equal(-1, 12.rows <=> 24.rows)
  end
end
