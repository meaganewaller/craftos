# frozen_string_literal: true

require "test_helper"

class FiberPatternSizeChartTest < Minitest::Test
  def chart
    FiberPattern::SizeChart.new
  end

  # -----------------------------
  # size
  # -----------------------------

  def test_size_returns_measurements_for_standard_size
    result = chart.size(:m)

    assert_equal 36.inches, result[:bust]
    assert_equal 28.inches, result[:waist]
    assert_equal 38.inches, result[:hip]
  end

  def test_size_returns_measurements_for_xs
    result = chart.size(:xs)

    assert_equal 28.inches, result[:bust]
    assert_equal 20.inches, result[:waist]
    assert_equal 30.inches, result[:hip]
  end

  def test_size_returns_measurements_for_xl
    result = chart.size(:xl)

    assert_equal 44.inches, result[:bust]
    assert_equal 36.inches, result[:waist]
    assert_equal 46.inches, result[:hip]
  end

  def test_size_raises_for_unknown_size
    assert_raises(ArgumentError) { chart.size(:jumbo) }
  end

  # -----------------------------
  # sizes
  # -----------------------------

  def test_sizes_returns_all_size_names
    expected = %i[xs s m l xl xxl xxxl xxxxl xxxxxl]

    assert_equal expected, chart.sizes
  end

  # -----------------------------
  # closest_size
  # -----------------------------

  def test_closest_size_returns_exact_match
    assert_equal :m, chart.closest_size(bust: 36.inches, waist: 28.inches, hip: 38.inches)
  end

  def test_closest_size_returns_nearest_size
    assert_equal :m, chart.closest_size(bust: 37.inches, waist: 29.inches, hip: 39.inches)
  end

  def test_closest_size_with_single_measurement
    assert_equal :l, chart.closest_size(bust: 40.inches)
  end

  def test_closest_size_between_sizes_picks_closer
    assert_equal :s, chart.closest_size(bust: 33.inches)
  end

  def test_closest_size_raises_with_no_comparable_measurements
    assert_raises(ArgumentError) { chart.closest_size(inseam: 30.inches) }
  end

  # -----------------------------
  # body_measurements_for
  # -----------------------------

  def test_body_measurements_for_returns_body_measurements_object
    result = chart.body_measurements_for(:m)

    assert_instance_of FiberPattern::BodyMeasurements, result
    assert_equal 36.inches, result.bust
    assert_equal 28.inches, result.waist
    assert_equal 38.inches, result.hip
  end

  # -----------------------------
  # custom chart
  # -----------------------------

  def test_custom_chart_data
    custom = FiberPattern::SizeChart.new(chart: {
      small: {chest: 34, length: 28},
      large: {chest: 42, length: 30}
    })

    assert_equal 34.inches, custom.size(:small)[:chest]
    assert_equal 42.inches, custom.size(:large)[:chest]
    assert_equal %i[small large], custom.sizes
  end
end
