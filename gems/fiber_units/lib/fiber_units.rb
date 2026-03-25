require_relative "fiber_units/version"
require_relative "fiber_units/errors"
require_relative "fiber_units/measurement"
require_relative "fiber_units/ratio"

require_relative "fiber_units/conversions/length_conversion"
require_relative "fiber_units/conversions/weight_conversion"

require_relative "fiber_units/dimensions/length"
require_relative "fiber_units/dimensions/weight"
require_relative "fiber_units/dimensions/count"
require_relative "fiber_units/dimensions/stitch_count"
require_relative "fiber_units/dimensions/row_count"
require_relative "fiber_units/dimensions/needle_size"
require_relative "fiber_units/dimensions/hook_size"

require_relative "numeric_extensions"

# Typed measurements and counts for fiber arts calculations.
#
# The library provides dimension-specific value objects for common craft
# measurements such as length, weight, stitch counts, and row counts.
# It also extends `Numeric` with constructors like `4.inches` and
# `20.stitches` for readable pattern math.
module FiberUnits
end
