# frozen_string_literal: true

require "test_helper"

class FiberPatternGradeRulesTest < Minitest::Test
  # -----------------------------
  # step_for
  # -----------------------------

  def test_step_for_returns_step_value
    rules = FiberPattern::GradeRules.new(
      bust: {step: 2.inches},
      waist: {step: 2.inches}
    )

    assert_equal 2.inches, rules.step_for(:bust)
  end

  def test_step_for_raises_for_unknown_measurement
    rules = FiberPattern::GradeRules.new(bust: {step: 2.inches})

    assert_raises(ArgumentError) { rules.step_for(:hip) }
  end

  # -----------------------------
  # measurements
  # -----------------------------

  def test_measurements_returns_all_defined_names
    rules = FiberPattern::GradeRules.new(
      bust: {step: 2.inches},
      waist: {step: 2.inches},
      hip: {step: 2.inches}
    )

    assert_equal %i[bust waist hip], rules.measurements
  end

  # -----------------------------
  # validation
  # -----------------------------

  def test_raises_when_rule_missing_step_key
    assert_raises(ArgumentError) do
      FiberPattern::GradeRules.new(bust: {amount: 2.inches})
    end
  end

  def test_raises_when_rule_is_not_a_hash
    assert_raises(ArgumentError) do
      FiberPattern::GradeRules.new(bust: 2.inches)
    end
  end
end
