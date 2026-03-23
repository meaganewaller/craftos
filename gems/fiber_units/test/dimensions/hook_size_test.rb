# frozen_string_literal: true

require "test_helper"

class FiberUnitsHookSizeTest < Minitest::Test
  # -----------------------------
  # Initialization
  # -----------------------------

  def test_initialization_stores_value_and_system
    hook = FiberUnits::HookSize.new(5.0, :mm)

    assert_equal 5.0, hook.value
    assert_equal :mm, hook.system
  end

  def test_initialization_with_us
    hook = FiberUnits::HookSize.new("H/8", :us)

    assert_equal "H/8", hook.value
    assert_equal :us, hook.system
  end

  def test_initialization_with_unknown_system_raises
    assert_raises(FiberUnits::InvalidUnitError) do
      FiberUnits::HookSize.new(5.0, :uk)
    end
  end

  def test_initialization_with_unknown_size_raises
    assert_raises(FiberUnits::InvalidUnitError) do
      FiberUnits::HookSize.new(999, :mm)
    end
  end

  # -----------------------------
  # Conversion
  # -----------------------------

  def test_mm_to_us
    hook = FiberUnits::HookSize.new(5.0, :mm)
    result = hook.to(:us)

    assert_equal "H/8", result.value
    assert_equal :us, result.system
  end

  def test_us_to_mm
    hook = FiberUnits::HookSize.new("H/8", :us)
    result = hook.to(:mm)

    assert_equal 5.0, result.value
    assert_equal :mm, result.system
  end

  def test_converts_small_hook
    hook = FiberUnits::HookSize.new("B/1", :us)
    result = hook.to(:mm)

    assert_equal 2.25, result.value
  end

  def test_converts_large_hook
    hook = FiberUnits::HookSize.new("S", :us)
    result = hook.to(:mm)

    assert_equal 19.0, result.value
  end

  def test_conversion_to_unknown_system_raises
    hook = FiberUnits::HookSize.new(5.0, :mm)

    assert_raises(FiberUnits::InvalidUnitError) do
      hook.to(:uk)
    end
  end

  # -----------------------------
  # to_mm
  # -----------------------------

  def test_to_mm_from_mm
    assert_equal 5.0, FiberUnits::HookSize.new(5.0, :mm).to_mm
  end

  def test_to_mm_from_us
    assert_equal 5.0, FiberUnits::HookSize.new("H/8", :us).to_mm
  end

  # -----------------------------
  # Comparison
  # -----------------------------

  def test_compares_sizes_across_systems
    mm5 = FiberUnits::HookSize.new(5.0, :mm)
    us_h8 = FiberUnits::HookSize.new("H/8", :us)

    assert_equal mm5, us_h8
  end

  def test_larger_hook_is_greater
    small = FiberUnits::HookSize.new("B/1", :us)
    large = FiberUnits::HookSize.new("H/8", :us)

    assert large > small
  end

  def test_spaceship_returns_nil_for_non_hook
    assert_nil(FiberUnits::HookSize.new(5.0, :mm) <=> "not a hook")
  end

  def test_not_equal_to_different_size
    refute_equal FiberUnits::HookSize.new(5.0, :mm), FiberUnits::HookSize.new(6.0, :mm)
  end

  def test_not_equal_to_non_hook
    refute_equal FiberUnits::HookSize.new(5.0, :mm), 5.0
  end

  # -----------------------------
  # to_s / inspect
  # -----------------------------

  def test_to_s_mm
    assert_equal "5.0mm hook", FiberUnits::HookSize.new(5.0, :mm).to_s
  end

  def test_to_s_us
    assert_equal "US H/8 hook", FiberUnits::HookSize.new("H/8", :us).to_s
  end

  def test_inspect
    hook = FiberUnits::HookSize.new("H/8", :us)

    assert_equal "#<FiberUnits::HookSize US H/8 hook>", hook.inspect
  end

  # -----------------------------
  # Frozen
  # -----------------------------

  def test_instances_are_frozen
    assert FiberUnits::HookSize.new(5.0, :mm).frozen?
  end
end
