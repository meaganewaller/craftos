# frozen_string_literal: true

require "test_helper"

class StashServiceTest < Minitest::Test
  def service
    StashService.new
  end

  def create_entry(attrs = {})
    defaults = {brand: "Malabrigo", line: "Rios", yardage: 210.0, skein_weight: 100.0, quantity: 1}
    service.add(defaults.merge(attrs))
  end

  def test_add_creates_entry
    result = create_entry
    assert result[:entry]
    assert_equal "Malabrigo", result[:entry][:brand]
  end

  def test_add_returns_errors_for_invalid_entry
    result = service.add(brand: "", line: "Rios", yardage: 210, skein_weight: 100)
    assert result[:errors]
  end

  def test_list_returns_all_entries
    create_entry
    create_entry(brand: "Cascade", line: "220")

    entries = service.list
    assert_equal 2, entries.length
  end

  def test_list_filters_by_search
    create_entry(brand: "Malabrigo", line: "Rios")
    create_entry(brand: "Cascade", line: "220")

    entries = service.list(search: "Cascade")
    assert_equal 1, entries.length
  end

  def test_remove_deletes_entry
    create_entry
    id = StashEntry.first.id

    assert service.remove(id)
    assert_equal 0, StashEntry.count
  end

  def test_remove_returns_false_for_missing
    refute service.remove(9999)
  end

  def test_check_yardage_across_all_entries
    create_entry(yardage: 210, quantity: 2)
    create_entry(brand: "Cascade", line: "220", yardage: 100, quantity: 1)

    result = service.check_yardage(500)
    assert result[:sufficient]
    assert_equal 520.0, result[:available]
  end
end
