# frozen_string_literal: true

require "test_helper"

class YarnSkeinWeightCategoryTest < Minitest::Test
  def test_returns_lace_for_1000_yards_per_100g
    assert_equal :lace, YarnSkein::WeightCategory.for(1000)
  end

  def test_returns_fingering_for_440_yards_per_100g
    assert_equal :fingering, YarnSkein::WeightCategory.for(440)
  end

  def test_returns_sport_for_320_yards_per_100g
    assert_equal :sport, YarnSkein::WeightCategory.for(320)
  end

  def test_returns_dk_for_250_yards_per_100g
    assert_equal :dk, YarnSkein::WeightCategory.for(250)
  end

  def test_returns_worsted_for_210_yards_per_100g
    assert_equal :worsted, YarnSkein::WeightCategory.for(210)
  end

  def test_returns_bulky_for_120_yards_per_100g
    assert_equal :bulky, YarnSkein::WeightCategory.for(120)
  end

  def test_returns_super_bulky_for_90_yards_per_100g
    assert_equal :super_bulky, YarnSkein::WeightCategory.for(90)
  end

  def test_returns_nil_for_negative_yards_per_100g
    assert_nil YarnSkein::WeightCategory.for(-10)
  end
end
