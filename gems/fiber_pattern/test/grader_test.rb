# frozen_string_literal: true

require "test_helper"

class FiberPatternGraderTest < Minitest::Test
  def rules
    FiberPattern::GradeRules.new(
      bust: {step: 2.inches},
      waist: {step: 2.inches},
      hip: {step: 2.inches}
    )
  end

  def base_measurements
    {bust: 36.inches, waist: 30.inches, hip: 38.inches}
  end

  def grader
    FiberPattern::Grader.new(
      base_size: :m,
      measurements: base_measurements,
      rules: rules
    )
  end

  # -----------------------------
  # size
  # -----------------------------

  def test_size_returns_base_measurements_for_base_size
    result = grader.size(:m)

    assert_equal 36.inches, result[:bust]
    assert_equal 30.inches, result[:waist]
    assert_equal 38.inches, result[:hip]
  end

  def test_size_grades_up_one_step
    result = grader.size(:l)

    assert_equal 38.inches, result[:bust]
    assert_equal 32.inches, result[:waist]
    assert_equal 40.inches, result[:hip]
  end

  def test_size_grades_up_multiple_steps
    result = grader.size(:xl)

    assert_equal 40.inches, result[:bust]
    assert_equal 34.inches, result[:waist]
    assert_equal 42.inches, result[:hip]
  end

  def test_size_grades_down
    result = grader.size(:s)

    assert_equal 34.inches, result[:bust]
    assert_equal 28.inches, result[:waist]
    assert_equal 36.inches, result[:hip]
  end

  def test_size_grades_down_to_xs
    result = grader.size(:xs)

    assert_equal 32.inches, result[:bust]
    assert_equal 26.inches, result[:waist]
    assert_equal 34.inches, result[:hip]
  end

  def test_size_raises_for_unknown_size
    assert_raises(ArgumentError) { grader.size(:jumbo) }
  end

  # -----------------------------
  # all_sizes
  # -----------------------------

  def test_all_sizes_returns_hash_of_all_sizes
    result = grader.all_sizes

    assert_equal FiberPattern::Grader::SIZES, result.keys
    assert_equal 36.inches, result[:m][:bust]
    assert_equal 38.inches, result[:l][:bust]
    assert_equal 34.inches, result[:s][:bust]
  end

  # -----------------------------
  # custom sizes
  # -----------------------------

  def test_custom_size_list
    custom_grader = FiberPattern::Grader.new(
      base_size: :m,
      measurements: base_measurements,
      rules: rules,
      sizes: %i[s m l]
    )

    result = custom_grader.all_sizes

    assert_equal %i[s m l], result.keys
  end

  # -----------------------------
  # fractional steps
  # -----------------------------

  def test_fractional_step_values
    fractional_rules = FiberPattern::GradeRules.new(
      sleeve_length: {step: 0.5.inches}
    )

    g = FiberPattern::Grader.new(
      base_size: :m,
      measurements: {sleeve_length: 18.inches},
      rules: fractional_rules
    )

    assert_equal 18.5.inches, g.size(:l)[:sleeve_length]
    assert_equal 17.5.inches, g.size(:s)[:sleeve_length]
  end

  # -----------------------------
  # validation
  # -----------------------------

  def test_raises_for_invalid_base_size
    assert_raises(ArgumentError) do
      FiberPattern::Grader.new(
        base_size: :jumbo,
        measurements: base_measurements,
        rules: rules
      )
    end
  end

  def test_raises_when_measurement_has_no_rule
    incomplete_rules = FiberPattern::GradeRules.new(bust: {step: 2.inches})

    assert_raises(ArgumentError) do
      FiberPattern::Grader.new(
        base_size: :m,
        measurements: base_measurements,
        rules: incomplete_rules
      )
    end
  end
end
