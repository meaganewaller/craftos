# frozen_string_literal: true

require "test_helper"

class FiberPatternShapingTest < Minitest::Test
  # -----------------------------
  # total_changes
  # -----------------------------

  def test_total_changes_for_decrease
    shaping = FiberPattern::Shaping.new(
      from: 60.stitches,
      to: 40.stitches,
      over: 30.rows,
      method: :decrease
    )

    assert_equal 10, shaping.total_changes
  end

  def test_total_changes_for_increase
    shaping = FiberPattern::Shaping.new(
      from: 40.stitches,
      to: 60.stitches,
      over: 30.rows,
      method: :increase
    )

    assert_equal 10, shaping.total_changes
  end

  def test_total_changes_with_custom_stitches_per_event
    shaping = FiberPattern::Shaping.new(
      from: 60.stitches,
      to: 40.stitches,
      over: 30.rows,
      method: :decrease,
      stitches_per_event: 4
    )

    assert_equal 5, shaping.total_changes
  end

  # -----------------------------
  # every_n_rows
  # -----------------------------

  def test_every_n_rows_for_even_distribution
    shaping = FiberPattern::Shaping.new(
      from: 60.stitches,
      to: 40.stitches,
      over: 30.rows,
      method: :decrease
    )

    assert_equal 3, shaping.every_n_rows
  end

  def test_every_n_rows_with_remainder
    shaping = FiberPattern::Shaping.new(
      from: 60.stitches,
      to: 40.stitches,
      over: 25.rows,
      method: :decrease
    )

    assert_equal 2, shaping.every_n_rows
  end

  def test_every_n_rows_returns_zero_when_no_changes
    shaping = FiberPattern::Shaping.new(
      from: 40.stitches,
      to: 40.stitches,
      over: 30.rows,
      method: :decrease
    )

    assert_equal 0, shaping.every_n_rows
  end

  # -----------------------------
  # schedule
  # -----------------------------

  def test_schedule_for_even_decrease
    shaping = FiberPattern::Shaping.new(
      from: 60.stitches,
      to: 40.stitches,
      over: 30.rows,
      method: :decrease
    )

    schedule = shaping.schedule

    assert_equal 10, schedule.length
    assert_equal({row: 3, action: :dec}, schedule.first)
    assert_equal({row: 30, action: :dec}, schedule.last)
    assert(schedule.all? { |e| e[:action] == :dec })
  end

  def test_schedule_for_increase
    shaping = FiberPattern::Shaping.new(
      from: 40.stitches,
      to: 50.stitches,
      over: 20.rows,
      method: :increase
    )

    schedule = shaping.schedule

    assert_equal 5, schedule.length
    assert(schedule.all? { |e| e[:action] == :inc })
  end

  def test_schedule_distributes_remainder_evenly
    shaping = FiberPattern::Shaping.new(
      from: 50.stitches,
      to: 40.stitches,
      over: 17.rows,
      method: :decrease
    )

    schedule = shaping.schedule
    rows = schedule.map { |e| e[:row] }

    assert_equal 5, schedule.length
    # 17 rows / 5 changes = 3 base + 2 remainder
    # First 2 intervals get 4 rows, last 3 get 3 rows
    assert_equal [4, 8, 11, 14, 17], rows
  end

  def test_schedule_empty_when_no_changes_needed
    shaping = FiberPattern::Shaping.new(
      from: 40.stitches,
      to: 40.stitches,
      over: 30.rows,
      method: :decrease
    )

    assert_empty shaping.schedule
  end

  # -----------------------------
  # validation
  # -----------------------------

  def test_raises_for_invalid_method
    assert_raises(ArgumentError) do
      FiberPattern::Shaping.new(
        from: 60.stitches,
        to: 40.stitches,
        over: 30.rows,
        method: :invalid
      )
    end
  end

  def test_raises_when_decrease_direction_is_wrong
    assert_raises(ArgumentError) do
      FiberPattern::Shaping.new(
        from: 40.stitches,
        to: 60.stitches,
        over: 30.rows,
        method: :decrease
      )
    end
  end

  def test_raises_when_increase_direction_is_wrong
    assert_raises(ArgumentError) do
      FiberPattern::Shaping.new(
        from: 60.stitches,
        to: 40.stitches,
        over: 30.rows,
        method: :increase
      )
    end
  end

  def test_raises_for_zero_rows
    assert_raises(ArgumentError) do
      FiberPattern::Shaping.new(
        from: 60.stitches,
        to: 40.stitches,
        over: 0.rows,
        method: :decrease
      )
    end
  end
end
