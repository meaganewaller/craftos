# frozen_string_literal: true

require "test_helper"

class FiberUnits::VersionTest < Minitest::Test
  def test_has_a_version_number
    refute_nil FiberUnits::VERSION
    assert_match(/^\d+\.\d+\.\d+$/, FiberUnits::VERSION)
  end
end
