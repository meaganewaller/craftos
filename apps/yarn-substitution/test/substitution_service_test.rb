# frozen_string_literal: true

require "test_helper"

class SubstitutionServiceTest < Minitest::Test
  def test_builds_target_yarn_from_attributes
    service = SubstitutionService.new(
      target_attrs: {brand: "Test", line: "Yarn", yardage: 210, skein_weight: 100},
      catalog_data: []
    )

    assert_equal "Test", service.target.brand
    assert_equal "Yarn", service.target.line
  end

  def test_target_info_returns_weight_category_and_grist
    service = SubstitutionService.new(
      target_attrs: {yardage: 210, skein_weight: 100},
      catalog_data: []
    )

    info = service.target_info
    assert_equal :worsted, info[:weight_category]
    assert_equal 210.0, info[:yards_per_100g]
  end

  def test_matches_returns_compatible_yarns
    service = SubstitutionService.new(
      target_attrs: {yardage: 210, skein_weight: 100},
      catalog_data: [
        {brand: "A", line: "Match", yardage: 200, skein_weight: 100},
        {brand: "B", line: "TooFar", yardage: 400, skein_weight: 100}
      ]
    )

    results = service.matches
    assert_equal 1, results.length
    assert_equal "A", results.first.brand
  end

  def test_matches_filters_by_fiber
    service = SubstitutionService.new(
      target_attrs: {yardage: 210, skein_weight: 100},
      catalog_data: [
        {brand: "A", line: "Wool", yardage: 200, skein_weight: 100, fiber_content: {wool: 100}},
        {brand: "B", line: "Cotton", yardage: 200, skein_weight: 100, fiber_content: {cotton: 100}}
      ]
    )

    results = service.matches(fiber: :wool)
    assert_equal 1, results.length
    assert_equal "A", results.first.brand
  end

  def test_matches_with_custom_tolerance
    service = SubstitutionService.new(
      target_attrs: {yardage: 210, skein_weight: 100},
      catalog_data: [
        {brand: "A", line: "Close", yardage: 200, skein_weight: 100}
      ]
    )

    assert_equal 1, service.matches(tolerance: 0.15).length
    assert_equal 0, service.matches(tolerance: 0.01).length
  end

  def test_builds_fiber_content_on_catalog_yarns
    service = SubstitutionService.new(
      target_attrs: {yardage: 210, skein_weight: 100},
      catalog_data: [
        {brand: "A", line: "Blend", yardage: 200, skein_weight: 100, fiber_content: {wool: 80, nylon: 20}}
      ]
    )

    yarn = service.catalog.first
    assert yarn.fiber_content.contains?(:wool)
    assert yarn.fiber_content.contains?(:nylon)
  end
end
