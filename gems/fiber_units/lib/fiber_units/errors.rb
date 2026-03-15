module FiberUnits
  # Raised when an operation mixes incompatible dimensions.
  class DimensionError < StandardError; end

  # Raised when a requested unit is not defined for a dimension.
  class InvalidUnitError < StandardError; end
end
