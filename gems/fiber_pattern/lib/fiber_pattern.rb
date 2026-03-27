# frozen_string_literal: true

require "fiber_units"
require "fiber_gauge"
require_relative "fiber_pattern/version"
require_relative "fiber_pattern/sizing"
require_relative "fiber_pattern/repeat"
require_relative "fiber_pattern/stitch_pattern"
require_relative "fiber_pattern/scaling"
require_relative "fiber_pattern/shaping"
require_relative "fiber_pattern/grade_rules"
require_relative "fiber_pattern/grader"
require_relative "fiber_pattern/body_measurements"
require_relative "fiber_pattern/ease"
require_relative "fiber_pattern/garment_sizing"
require_relative "fiber_pattern/size_chart"

# Utilities for generating fiber pattern measurements from gauge data.
module FiberPattern
  # Base error type for gem-specific failures.
  class Error < StandardError; end
end
