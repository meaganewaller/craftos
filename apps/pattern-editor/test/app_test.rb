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
  end

  def test_get_root_includes_stitch_pattern_select
    request_get "/"
    assert_includes last_response.body, "stitchPattern"
  end

  def test_get_root_includes_pieces_list_container
    request_get "/"
    assert_includes last_response.body, "piecesList"
  end

  def test_get_root_includes_add_piece_button
    request_get "/"
    assert_includes last_response.body, "addPiece()"
    assert_includes last_response.body, "+ add piece"
  end

  def test_get_root_includes_calculate_all_button
    request_get "/"
    assert_includes last_response.body, "calculateAll()"
    assert_includes last_response.body, "calculate all pieces!"
  end

  def test_get_root_includes_preset_buttons
    request_get "/"
    assert_includes last_response.body, "pullover"
    assert_includes last_response.body, "cardigan"
    assert_includes last_response.body, "vest"
  end

  def test_get_root_includes_results_container
    request_get "/"
    assert_includes last_response.body, "resultsContainer"
  end
end
