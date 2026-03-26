# frozen_string_literal: true

require "test_helper"

class StashEntryTest < Minitest::Test
  def test_total_yardage
    entry = StashEntry.new(brand: "Test", line: "Yarn", yardage: 210, skein_weight: 100, quantity: 3)
    assert_equal 630, entry.total_yardage
  end

  def test_to_hash_includes_all_fields
    user = create_user
    entry = StashEntry.create(brand: "Test", line: "Yarn", colorway: "Blue", yardage: 210, skein_weight: 100, quantity: 2, user_id: user.id)
    hash = entry.to_hash

    assert_equal "Test", hash[:brand]
    assert_equal "Blue", hash[:colorway]
    assert_equal 420, hash[:total_yardage]
  end

  def test_validates_brand_required
    entry = StashEntry.new(brand: "", line: "Yarn", yardage: 210, skein_weight: 100)
    refute entry.valid?
  end

  def test_validates_yardage_positive
    entry = StashEntry.new(brand: "Test", line: "Yarn", yardage: 0, skein_weight: 100)
    refute entry.valid?
  end

  def test_validates_quantity_positive
    entry = StashEntry.new(brand: "Test", line: "Yarn", yardage: 210, skein_weight: 100, quantity: 0)
    refute entry.valid?
  end
end
