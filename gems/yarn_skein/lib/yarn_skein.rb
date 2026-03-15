# frozen_string_literal: true

require "fiber_units"
require_relative "yarn_skein/version"
require_relative "yarn_skein/weight_category"
require_relative "yarn_skein/fiber_blend"
require_relative "yarn_skein/yarn"

# Domain objects for describing yarn skeins, fiber blends, and weight classes.
#
# `YarnSkein` builds on `fiber_units` so yardage and weight remain typed
# values throughout calculations such as grist, total yardage, and category
# lookups.
module YarnSkein
  # Base error class for library-specific failures.
  class Error < StandardError; end
end
