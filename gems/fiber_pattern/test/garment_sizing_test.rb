# frozen_string_literal: true

require "test_helper"

class FiberPatternGarmentSizingTest < Minitest::Test
  def body
    FiberPattern::BodyMeasurements.new(
      bust: 36.inches,
      waist: 30.inches,
      hip: 38.inches
    )
  end

  def ease
    FiberPattern::Ease.new(
      bust: 4.inches,
      waist: 2.inches,
      hip: 2.inches
    )
  end

  def garment
    FiberPattern::GarmentSizing.new(body: body, ease: ease)
  end

  # -----------------------------
  # dimension
  # -----------------------------

  def test_dimension_adds_body_and_ease
    assert_equal 40.inches, garment.dimension(:bust)
    assert_equal 32.inches, garment.dimension(:waist)
    assert_equal 40.inches, garment.dimension(:hip)
  end

  def test_dimension_raises_for_unknown_measurement
    assert_raises(ArgumentError) { garment.dimension(:inseam) }
  end

  # -----------------------------
  # accessors
  # -----------------------------

  def test_accessor_methods_return_finished_dimensions
    assert_equal 40.inches, garment.bust
    assert_equal 32.inches, garment.waist
    assert_equal 40.inches, garment.hip
  end

  # -----------------------------
  # bracket access
  # -----------------------------

  def test_bracket_access_returns_finished_dimension
    assert_equal 40.inches, garment[:bust]
  end

  # -----------------------------
  # dimensions
  # -----------------------------

  def test_dimensions_returns_all_finished_measurements
    result = garment.dimensions

    assert_equal 40.inches, result[:bust]
    assert_equal 32.inches, result[:waist]
    assert_equal 40.inches, result[:hip]
  end

  # -----------------------------
  # partial ease
  # -----------------------------

  def test_body_measurement_without_ease_uses_body_value
    partial_ease = FiberPattern::Ease.new(bust: 4.inches)
    g = FiberPattern::GarmentSizing.new(body: body, ease: partial_ease)

    assert_equal 40.inches, g.bust
    assert_equal 30.inches, g.waist
    assert_equal 38.inches, g.hip
  end

  # -----------------------------
  # negative ease
  # -----------------------------

  def test_negative_ease_subtracts_from_body
    tight_ease = FiberPattern::Ease.new(bust: -2.inches)
    g = FiberPattern::GarmentSizing.new(body: body, ease: tight_ease)

    assert_equal 34.inches, g.bust
  end

  # -----------------------------
  # validation
  # -----------------------------

  def test_raises_when_ease_has_measurement_not_in_body
    bad_ease = FiberPattern::Ease.new(inseam: 2.inches)

    assert_raises(ArgumentError) do
      FiberPattern::GarmentSizing.new(body: body, ease: bad_ease)
    end
  end
end
