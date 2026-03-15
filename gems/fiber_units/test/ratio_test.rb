# frozen_string_literal: true

require "test_helper"

class FiberUnitsRatioTest < Minitest::Test
  def test_stores_numerator_and_denominator
    ratio = 210.yards / 100.grams

    assert_instance_of FiberUnits::Length, ratio.numerator
    assert_instance_of FiberUnits::Weight, ratio.denominator
  end

  def test_computes_ratio_value
    ratio = 210.yards / 100.grams

    assert_equal 2.10, ratio.value.round(2)
  end

  def test_formats_nicely
    ratio = 210.yards / 100.grams

    assert_includes ratio.to_s, "yards"
  end
end
