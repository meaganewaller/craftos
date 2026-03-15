# frozen_string_literal: true

require "test_helper"

class YarnSkein::VersionTest < Minitest::Test
  def test_has_a_version_number
    refute_nil YarnSkein::VERSION
    assert_match(/^\d+\.\d+\.\d+$/, YarnSkein::VERSION)
  end
end
