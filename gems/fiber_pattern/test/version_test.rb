# frozen_string_literal: true

require "test_helper"

class FiberPattern::VersionTest < Minitest::Test
  def test_has_a_version_number
    refute_nil FiberPattern::VERSION
    assert_match(/^\d+\.\d+\.\d+$/, FiberPattern::VERSION)
  end
end
