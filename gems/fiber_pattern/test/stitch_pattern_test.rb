# frozen_string_literal: true

require "test_helper"

class StitchPatternTest < Minitest::Test
  # -----------------------------
  # initialization
  # -----------------------------

  def test_initializes_with_name_and_defaults
    sp = FiberPattern::StitchPattern.new(name: "Stockinette")

    assert_equal "Stockinette", sp.name
    assert_equal 1.0, sp.width_factor
    assert_equal 1.0, sp.yarn_factor
    assert_nil sp.repeat
  end

  def test_initializes_with_all_attributes
    repeat = FiberPattern::Repeat.new(multiple: 8.stitches, offset: 2.stitches)
    sp = FiberPattern::StitchPattern.new(
      name: "2x2 Cable Rib",
      repeat: repeat,
      width_factor: 0.85,
      yarn_factor: 1.20
    )

    assert_equal "2x2 Cable Rib", sp.name
    assert_equal repeat, sp.repeat
    assert_equal 0.85, sp.width_factor
    assert_equal 1.20, sp.yarn_factor
  end

  # -----------------------------
  # validation
  # -----------------------------

  def test_raises_on_empty_name
    assert_raises(ArgumentError) do
      FiberPattern::StitchPattern.new(name: "")
    end
  end

  def test_raises_on_nil_name
    assert_raises(ArgumentError) do
      FiberPattern::StitchPattern.new(name: nil)
    end
  end

  def test_raises_on_zero_width_factor
    assert_raises(ArgumentError) do
      FiberPattern::StitchPattern.new(name: "Bad", width_factor: 0)
    end
  end

  def test_raises_on_negative_yarn_factor
    assert_raises(ArgumentError) do
      FiberPattern::StitchPattern.new(name: "Bad", yarn_factor: -1)
    end
  end

  # -----------------------------
  # adjust_width
  # -----------------------------

  def test_adjust_width_for_pattern_that_pulls_in
    sp = FiberPattern::StitchPattern.new(name: "Rib", width_factor: 0.85)

    result = sp.adjust_width(20.inches)

    assert_equal 23.53, result.value
    assert_equal :inches, result.unit
  end

  def test_adjust_width_for_stockinette_is_unchanged
    sp = FiberPattern::StitchPattern.stockinette

    result = sp.adjust_width(20.inches)

    assert_equal 20.0, result.value
    assert_equal :inches, result.unit
  end

  # -----------------------------
  # adjust_yardage
  # -----------------------------

  def test_adjust_yardage_increases_for_cables
    sp = FiberPattern::StitchPattern.new(name: "Cable", yarn_factor: 1.20)

    result = sp.adjust_yardage(500.yards)

    assert_equal 600.0, result.value
    assert_equal :yards, result.unit
  end

  def test_adjust_yardage_for_stockinette_is_unchanged
    sp = FiberPattern::StitchPattern.stockinette

    result = sp.adjust_yardage(500.yards)

    assert_equal 500.0, result.value
    assert_equal :yards, result.unit
  end

  # -----------------------------
  # presets
  # -----------------------------

  def test_stockinette_preset
    sp = FiberPattern::StitchPattern.stockinette

    assert_equal "Stockinette", sp.name
    assert_equal 1.0, sp.width_factor
    assert_equal 1.0, sp.yarn_factor
    assert_nil sp.repeat
  end

  def test_garter_preset
    sp = FiberPattern::StitchPattern.garter

    assert_equal "Garter", sp.name
    assert_equal 1.05, sp.yarn_factor
    assert_nil sp.repeat
  end

  def test_rib_1x1_preset
    sp = FiberPattern::StitchPattern.rib_1x1

    assert_equal "1x1 Rib", sp.name
    assert_equal 0.90, sp.width_factor
    assert_equal 1.10, sp.yarn_factor
    assert_equal 2.stitches, sp.repeat.multiple
  end

  def test_rib_2x2_preset
    sp = FiberPattern::StitchPattern.rib_2x2

    assert_equal "2x2 Rib", sp.name
    assert_equal 0.85, sp.width_factor
    assert_equal 1.12, sp.yarn_factor
    assert_equal 4.stitches, sp.repeat.multiple
  end

  def test_seed_preset
    sp = FiberPattern::StitchPattern.seed

    assert_equal "Seed Stitch", sp.name
    assert_equal 0.95, sp.width_factor
    assert_equal 1.05, sp.yarn_factor
    assert_equal 2.stitches, sp.repeat.multiple
  end

  # -----------------------------
  # Sizing integration
  # -----------------------------

  def gauge
    FiberGauge::Gauge.new(
      stitches: 18.stitches,
      rows: 24.rows,
      width: 4.inches
    )
  end

  def test_sizing_accounts_for_stitch_pattern_width_factor
    sp = FiberPattern::StitchPattern.new(name: "Rib", width_factor: 0.85)
    sizing = FiberPattern::Sizing.new(gauge: gauge, stitch_pattern: sp)

    stitches = sizing.cast_on_for(20.inches)

    # 20 / 0.85 = 23.53 inches stockinette-equivalent
    # 18 stitches / 4 inches * 23.53 = 105.88 → 106 stitches
    assert_equal 106.stitches, stitches
  end

  def test_sizing_with_stitch_pattern_and_repeat
    sp = FiberPattern::StitchPattern.rib_2x2
    sizing = FiberPattern::Sizing.new(
      gauge: gauge,
      repeat: sp.repeat,
      stitch_pattern: sp
    )

    stitches = sizing.cast_on_for(20.inches)

    # 20 / 0.85 = 23.53 → 18/4 * 23.53 = 105.88 → 106, rounded to repeat of 4 → 108
    assert_equal 108.stitches, stitches
  end
end
