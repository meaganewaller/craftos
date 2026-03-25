# frozen_string_literal: true

require "test_helper"

class FiberUnitsNeedleSizeTest < Minitest::Test
  # -----------------------------
  # Initialization
  # -----------------------------

  def test_initialization_stores_value_and_system
    needle = FiberUnits::NeedleSize.new(8, :us)

    assert_equal 8, needle.value
    assert_equal :us, needle.system
  end

  def test_initialization_with_mm
    needle = FiberUnits::NeedleSize.new(5.0, :mm)

    assert_equal 5.0, needle.value
    assert_equal :mm, needle.system
  end

  def test_initialization_with_uk
    needle = FiberUnits::NeedleSize.new(6, :uk)

    assert_equal 6, needle.value
    assert_equal :uk, needle.system
  end

  def test_initialization_with_unknown_system_raises
    assert_raises(FiberUnits::InvalidUnitError) do
      FiberUnits::NeedleSize.new(8, :jp)
    end
  end

  def test_initialization_with_unknown_size_raises
    assert_raises(FiberUnits::InvalidUnitError) do
      FiberUnits::NeedleSize.new(999, :us)
    end
  end

  # -----------------------------
  # Conversion
  # -----------------------------

  def test_us_to_mm
    needle = FiberUnits::NeedleSize.new(8, :us)
    result = needle.to(:mm)

    assert_equal 5.0, result.value
    assert_equal :mm, result.system
  end

  def test_us_to_uk
    needle = FiberUnits::NeedleSize.new(8, :us)
    result = needle.to(:uk)

    assert_equal 6, result.value
    assert_equal :uk, result.system
  end

  def test_mm_to_us
    needle = FiberUnits::NeedleSize.new(5.0, :mm)
    result = needle.to(:us)

    assert_equal 8, result.value
    assert_equal :us, result.system
  end

  def test_mm_to_uk
    needle = FiberUnits::NeedleSize.new(5.0, :mm)
    result = needle.to(:uk)

    assert_equal 6, result.value
  end

  def test_uk_to_mm
    needle = FiberUnits::NeedleSize.new(6, :uk)
    result = needle.to(:mm)

    assert_equal 5.0, result.value
  end

  def test_uk_to_us
    needle = FiberUnits::NeedleSize.new(6, :uk)
    result = needle.to(:us)

    assert_equal 8, result.value
  end

  def test_conversion_to_unavailable_system_raises
    needle = FiberUnits::NeedleSize.new(4, :us) # US 4 = 3.5mm, no UK equivalent

    assert_raises(FiberUnits::InvalidUnitError) do
      needle.to(:uk)
    end
  end

  def test_conversion_to_unknown_system_raises
    needle = FiberUnits::NeedleSize.new(8, :us)

    assert_raises(FiberUnits::InvalidUnitError) do
      needle.to(:jp)
    end
  end

  # -----------------------------
  # to_mm
  # -----------------------------

  def test_to_mm_from_us
    assert_equal 5.0, FiberUnits::NeedleSize.new(8, :us).to_mm
  end

  def test_to_mm_from_mm
    assert_equal 5.0, FiberUnits::NeedleSize.new(5.0, :mm).to_mm
  end

  def test_to_mm_from_uk
    assert_equal 5.0, FiberUnits::NeedleSize.new(6, :uk).to_mm
  end

  # -----------------------------
  # Comparison
  # -----------------------------

  def test_compares_sizes_across_systems
    us8 = FiberUnits::NeedleSize.new(8, :us)
    mm5 = FiberUnits::NeedleSize.new(5.0, :mm)

    assert_equal us8, mm5
  end

  def test_larger_needle_is_greater
    us6 = FiberUnits::NeedleSize.new(6, :us)
    us8 = FiberUnits::NeedleSize.new(8, :us)

    assert us8 > us6
  end

  def test_smaller_needle_is_less
    uk8 = FiberUnits::NeedleSize.new(8, :uk) # 4.0mm
    uk6 = FiberUnits::NeedleSize.new(6, :uk) # 5.0mm

    assert uk8 < uk6 # UK sizes go in reverse
  end

  def test_spaceship_returns_nil_for_non_needle
    assert_nil(FiberUnits::NeedleSize.new(8, :us) <=> "not a needle")
  end

  def test_not_equal_to_different_size
    refute_equal FiberUnits::NeedleSize.new(8, :us), FiberUnits::NeedleSize.new(6, :us)
  end

  def test_not_equal_to_non_needle
    refute_equal FiberUnits::NeedleSize.new(8, :us), 8
  end

  # -----------------------------
  # to_s / inspect
  # -----------------------------

  def test_to_s_mm
    assert_equal "5.0mm needle", FiberUnits::NeedleSize.new(5.0, :mm).to_s
  end

  def test_to_s_us
    assert_equal "US 8 needle", FiberUnits::NeedleSize.new(8, :us).to_s
  end

  def test_to_s_uk
    assert_equal "UK 6 needle", FiberUnits::NeedleSize.new(6, :uk).to_s
  end

  def test_inspect
    needle = FiberUnits::NeedleSize.new(8, :us)

    assert_equal "#<FiberUnits::NeedleSize US 8 needle>", needle.inspect
  end

  # -----------------------------
  # Frozen
  # -----------------------------

  def test_instances_are_frozen
    assert FiberUnits::NeedleSize.new(8, :us).frozen?
  end
end
