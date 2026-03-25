# frozen_string_literal: true

require "test_helper"

class FiberPatternEaseTest < Minitest::Test
  def ease
    FiberPattern::Ease.new(
      bust: 4.inches,
      waist: 2.inches,
      hip: 2.inches
    )
  end

  # -----------------------------
  # accessors
  # -----------------------------

  def test_accessor_methods_return_ease_values
    assert_equal 4.inches, ease.bust
    assert_equal 2.inches, ease.waist
    assert_equal 2.inches, ease.hip
  end

  def test_bracket_access_returns_ease_value
    assert_equal 4.inches, ease[:bust]
  end

  def test_bracket_access_returns_nil_for_unknown
    assert_nil ease[:inseam]
  end

  # -----------------------------
  # for
  # -----------------------------

  def test_for_returns_ease_value
    assert_equal 4.inches, ease.for(:bust)
  end

  def test_for_raises_for_unknown_measurement
    assert_raises(ArgumentError) { ease.for(:inseam) }
  end

  # -----------------------------
  # measurements
  # -----------------------------

  def test_measurements_returns_all_keys
    assert_equal %i[bust waist hip], ease.measurements
  end

  # -----------------------------
  # negative ease
  # -----------------------------

  def test_negative_ease_values
    negative = FiberPattern::Ease.new(bust: -2.inches)

    assert_equal(-2.inches, negative.bust)
  end

  # -----------------------------
  # validation
  # -----------------------------

  def test_raises_when_no_ease_values_given
    assert_raises(ArgumentError) { FiberPattern::Ease.new }
  end

  # -----------------------------
  # immutability
  # -----------------------------

  def test_data_is_frozen
    assert ease.data.frozen?
  end
end
