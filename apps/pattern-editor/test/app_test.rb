require "test_helper"

class PatternEditorAppTest < Minitest::Test
  def test_get_root_returns_200
    request_get "/"
    assert last_response.ok?
  end

  def test_get_root_renders_editor_form
    request_get "/"
    assert_includes last_response.body, "pattern editor"
    assert_includes last_response.body, "gaugeStitches"
    assert_includes last_response.body, "pieceWidth"
    assert_includes last_response.body, "pieceHeight"
  end

  def test_get_root_includes_stitch_pattern_select
    request_get "/"
    assert_includes last_response.body, "stitchPattern"
  end

  def test_get_root_includes_schematic_container
    request_get "/"
    assert_includes last_response.body, "schematic"
  end
end
