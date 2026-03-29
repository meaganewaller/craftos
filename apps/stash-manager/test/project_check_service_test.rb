# frozen_string_literal: true

require "test_helper"

class ProjectCheckServiceTest < Minitest::Test
  def setup
    existing = User.where(username: "projectcheck_user").first
    if existing
      existing.stash_entries_dataset.delete
      existing.delete
    end
    @user = create_user(username: "projectcheck_user")
  end

  def service
    ProjectCheckService.new(@user)
  end

  def add_entry(attrs = {})
    defaults = {brand: "Malabrigo", line: "Rios", yardage: 210.0, skein_weight: 100.0, quantity: 3}
    StashService.new(@user).add(defaults.merge(attrs))
  end

  def gauge_params
    {stitches: 18, rows: 24, width: 4, height: 4}
  end

  # --- Simple rectangle checks ---

  def test_check_rectangle_sufficient
    add_entry(yardage: 210, quantity: 10)
    id = @user.stash_entries_dataset.first.id

    check = service.check_rectangle(
      gauge_params: gauge_params,
      dimensions: {width: 20, height: 20},
      stash_entry_ids: [id]
    )

    assert_equal "simple", check[:mode]
    assert check[:estimated_yardage] > 0
    assert_equal 2100.0, check[:available_yardage]
    assert check[:sufficient]
    assert check[:surplus] > 0
    assert_equal 0, check[:shortage]
  end

  def test_check_rectangle_insufficient
    add_entry(yardage: 210, quantity: 1)
    id = @user.stash_entries_dataset.first.id

    check = service.check_rectangle(
      gauge_params: gauge_params,
      dimensions: {width: 60, height: 72},
      stash_entry_ids: [id]
    )

    assert_equal "simple", check[:mode]
    refute check[:sufficient]
    assert check[:shortage] > 0
    assert_equal 0, check[:surplus]
  end

  def test_check_rectangle_with_multiple_entries
    add_entry(yardage: 210, quantity: 5)
    add_entry(brand: "Cascade", line: "220", yardage: 220, quantity: 5)
    ids = @user.stash_entries_dataset.select_map(:id)

    check = service.check_rectangle(
      gauge_params: gauge_params,
      dimensions: {width: 20, height: 20},
      stash_entry_ids: ids
    )

    assert_equal 2150.0, check[:available_yardage]
  end

  def test_check_rectangle_no_entries
    check = service.check_rectangle(
      gauge_params: gauge_params,
      dimensions: {width: 20, height: 20},
      stash_entry_ids: [9999]
    )

    assert_equal "No matching stash entries found", check[:error]
  end

  # --- Colorwork checks ---

  def test_check_colorwork_stranded_sufficient
    add_entry(colorway: "Navy", yardage: 210, quantity: 10)
    main_id = @user.stash_entries_dataset.first.id
    add_entry(colorway: "Cream", yardage: 210, quantity: 10)
    contrast_id = @user.stash_entries_dataset.order(:id).last.id

    check = service.check_colorwork(
      gauge_params: gauge_params,
      dimensions: {width: 20, height: 20},
      technique: "stranded",
      color_assignments: {
        "main" => {"proportion" => 0.6, "stash_entry_ids" => [main_id]},
        "contrast" => {"proportion" => 0.4, "stash_entry_ids" => [contrast_id]}
      }
    )

    assert_equal "colorwork", check[:mode]
    assert_equal "stranded", check[:technique]
    assert check[:colors][:main][:sufficient]
    assert check[:colors][:contrast][:sufficient]
    assert check[:all_sufficient]
    assert check[:total_estimated_yardage] > 0
  end

  def test_check_colorwork_stranded_one_color_short
    add_entry(colorway: "Navy", yardage: 210, quantity: 10)
    main_id = @user.stash_entries_dataset.first.id
    add_entry(colorway: "Cream", yardage: 210, quantity: 1)
    contrast_id = @user.stash_entries_dataset.order(:id).last.id

    check = service.check_colorwork(
      gauge_params: gauge_params,
      dimensions: {width: 40, height: 40},
      technique: "stranded",
      color_assignments: {
        "main" => {"proportion" => 0.6, "stash_entry_ids" => [main_id]},
        "contrast" => {"proportion" => 0.4, "stash_entry_ids" => [contrast_id]}
      }
    )

    refute check[:all_sufficient]
    assert check[:colors][:main][:sufficient]
    refute check[:colors][:contrast][:sufficient]
    assert check[:colors][:contrast][:shortage] > 0
  end

  def test_check_colorwork_intarsia
    add_entry(colorway: "Red", yardage: 210, quantity: 10)
    left_id = @user.stash_entries_dataset.first.id
    add_entry(colorway: "Blue", yardage: 210, quantity: 10)
    right_id = @user.stash_entries_dataset.order(:id).last.id

    check = service.check_colorwork(
      gauge_params: gauge_params,
      dimensions: {width: 20, height: 20},
      technique: "intarsia",
      color_assignments: {
        "left" => {"proportion" => 0.5, "stash_entry_ids" => [left_id]},
        "right" => {"proportion" => 0.5, "stash_entry_ids" => [right_id]}
      }
    )

    assert_equal "intarsia", check[:technique]
    assert check[:all_sufficient]
  end

  def test_check_colorwork_invalid_proportions
    add_entry(yardage: 210, quantity: 5)
    id = @user.stash_entries_dataset.first.id

    assert_raises(ArgumentError) do
      service.check_colorwork(
        gauge_params: gauge_params,
        dimensions: {width: 20, height: 20},
        technique: "stranded",
        color_assignments: {
          "main" => {"proportion" => 0.5, "stash_entry_ids" => [id]},
          "contrast" => {"proportion" => 0.3, "stash_entry_ids" => [id]}
        }
      )
    end
  end

  def test_check_colorwork_invalid_technique
    add_entry(yardage: 210, quantity: 5)
    id = @user.stash_entries_dataset.first.id

    assert_raises(ArgumentError) do
      service.check_colorwork(
        gauge_params: gauge_params,
        dimensions: {width: 20, height: 20},
        technique: "mosaic",
        color_assignments: {
          "main" => {"proportion" => 1.0, "stash_entry_ids" => [id]}
        }
      )
    end
  end
end
