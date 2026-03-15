require_relative "test_helper"

class RepeatTest < Minitest::Test
  def test_adjust_rounds_up_to_nearest_multiple
    repeat = FiberPattern::Repeat.new(multiple: 8.stitches)

    result = repeat.adjust(171.stitches)

    assert_equal 176.stitches, result
  end

  def test_adjust_handles_repeat_offsets
    repeat = FiberPattern::Repeat.new(
      multiple: 8.stitches,
      offset: 2.stitches
    )

    result = repeat.adjust(171.stitches)

    assert_equal 178.stitches, result
  end
end
