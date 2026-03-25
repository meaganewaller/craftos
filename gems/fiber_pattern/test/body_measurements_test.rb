# frozen_string_literal: true

require "test_helper"

class FiberPatternBodyMeasurementsTest < Minitest::Test
  def body
    FiberPattern::BodyMeasurements.new(
      bust: 36.inches,
      waist: 30.inches,
      hip: 38.inches,
      arm_length: 24.inches
    )
  end

  # -----------------------------
  # accessors
  # -----------------------------

  def test_accessor_methods_return_measurements
    assert_equal 36.inches, body.bust
    assert_equal 30.inches, body.waist
    assert_equal 38.inches, body.hip
    assert_equal 24.inches, body.arm_length
  end

  def test_bracket_access_returns_measurement
    assert_equal 36.inches, body[:bust]
    assert_equal 30.inches, body[:waist]
  end

  def test_bracket_access_returns_nil_for_unknown
    assert_nil body[:inseam]
  end

  # -----------------------------
  # measurements
  # -----------------------------

  def test_measurements_returns_all_keys
    assert_equal %i[bust waist hip arm_length], body.measurements
  end

  # -----------------------------
  # to_h
  # -----------------------------

  def test_to_h_returns_hash_of_measurements
    result = body.to_h

    assert_equal 36.inches, result[:bust]
    assert_equal 30.inches, result[:waist]
    assert_equal 38.inches, result[:hip]
    assert_equal 24.inches, result[:arm_length]
  end

  # -----------------------------
  # validation
  # -----------------------------

  def test_raises_when_no_measurements_given
    assert_raises(ArgumentError) { FiberPattern::BodyMeasurements.new }
  end

  # -----------------------------
  # immutability
  # -----------------------------

  def test_data_is_frozen
    assert body.data.frozen?
  end
end
