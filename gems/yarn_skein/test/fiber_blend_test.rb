# frozen_string_literal: true

require "test_helper"

class YarnSkeinFiberBlendTest < Minitest::Test
  # -----------------------------
  # Initialization
  # -----------------------------

  def test_stores_fiber_percentages
    blend = YarnSkein::FiberBlend.new(
      merino_wool: 80,
      nylon: 20
    )

    assert_equal(
      {
        merino_wool: 80,
        nylon: 20
      },
      blend.fibers
    )
  end

  def test_raises_error_if_percentages_do_not_sum_to_100
    error = assert_raises(ArgumentError) do
      YarnSkein::FiberBlend.new(
        merino_wool: 50,
        nylon: 30
      )
    end

    assert_match(/must sum to 100/, error.message)
  end

  # -----------------------------
  # yards_per_100g
  # -----------------------------

  def test_calculates_yards_per_100_grams
    yarn = YarnSkein::Yarn.new(
      brand: "Malabrigo",
      line: "Rios",
      yardage: 210.yards,
      skein_weight: 100.grams
    )

    assert_equal 210, yarn.yards_per_100g
  end

  # -----------------------------
  # percentage
  # -----------------------------

  def test_returns_percentage_of_fiber
    blend = YarnSkein::FiberBlend.new(
      merino_wool: 80,
      nylon: 20
    )

    assert_equal 80, blend.percentage(:merino_wool)
  end

  def test_returns_zero_for_missing_fibers
    blend = YarnSkein::FiberBlend.new(
      merino_wool: 100
    )

    assert_equal 0, blend.percentage(:nylon)
  end

  # -----------------------------
  # contains?
  # -----------------------------

  def test_contains_returns_true_if_fiber_exists
    blend = YarnSkein::FiberBlend.new(
      merino_wool: 80,
      nylon: 20
    )

    assert blend.contains?(:nylon)
  end

  def test_contains_returns_false_if_fiber_does_not_exist
    blend = YarnSkein::FiberBlend.new(
      merino_wool: 100
    )

    refute blend.contains?(:nylon)
  end
end
