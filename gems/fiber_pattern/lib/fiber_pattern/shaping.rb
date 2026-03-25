# frozen_string_literal: true

module FiberPattern
  # Calculates evenly distributed shaping (increases or decreases) across a span of rows.
  #
  # @example Decreasing from 60 to 40 stitches over 30 rows
  #   shaping = FiberPattern::Shaping.new(
  #     from: 60.stitches,
  #     to: 40.stitches,
  #     over: 30.rows,
  #     method: :decrease
  #   )
  #   shaping.total_changes      # => 10
  #   shaping.every_n_rows       # => 3
  #   shaping.schedule           # => [{row: 1, action: :dec}, {row: 4, action: :dec}, ...]
  class Shaping
    # @return [FiberUnits::Stitches] starting stitch count
    # @return [FiberUnits::Stitches] ending stitch count
    # @return [FiberUnits::Rows] total rows available for shaping
    # @return [Symbol] shaping method (:increase or :decrease)
    # @return [Integer] stitches changed per shaping row (default 2 for paired shaping)
    attr_reader :from, :to, :over, :method, :stitches_per_event

    # @param from [FiberUnits::Stitches] starting stitch count
    # @param to [FiberUnits::Stitches] target stitch count
    # @param over [FiberUnits::Rows] number of rows available for shaping
    # @param method [Symbol] :increase or :decrease
    # @param stitches_per_event [Integer] stitches changed per shaping row (default 2 for paired shaping)
    def initialize(from:, to:, over:, method:, stitches_per_event: 2)
      validate!(from, to, over, method)
      @from = from
      @to = to
      @over = over
      @method = method
      @stitches_per_event = stitches_per_event
    end

    # Total number of shaping events needed.
    #
    # @return [Integer]
    def total_changes
      stitch_difference / stitches_per_event
    end

    # Base interval between shaping rows.
    #
    # @return [Integer]
    def every_n_rows
      return 0 if total_changes.zero?

      over.value / total_changes
    end

    # Row-by-row schedule of shaping events, distributing any remainder rows
    # evenly across the span.
    #
    # @return [Array<Hash>] each entry has :row and :action keys
    def schedule
      return [] if total_changes.zero?

      changes = total_changes
      rows_available = over.value
      action = (method == :decrease) ? :dec : :inc

      base_interval = rows_available / changes
      remainder = rows_available % changes

      schedule = []
      current_row = 0

      changes.times do |i|
        # Spread remainder evenly: the first `remainder` intervals get +1 row
        interval = base_interval + ((i < remainder) ? 1 : 0)
        current_row += interval
        schedule << {row: current_row, action: action}
      end

      schedule
    end

    private

    def stitch_difference
      (from.value - to.value).abs
    end

    def validate!(from, to, over, method)
      unless %i[increase decrease].include?(method)
        raise ArgumentError, "method must be :increase or :decrease, got #{method.inspect}"
      end

      if method == :decrease && from.value < to.value
        raise ArgumentError, "from must be greater than to for :decrease shaping"
      end

      if method == :increase && from.value > to.value
        raise ArgumentError, "from must be less than to for :increase shaping"
      end

      if over.value <= 0
        raise ArgumentError, "over must be a positive row count"
      end
    end
  end
end
