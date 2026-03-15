module FiberUnits
  # A distance measurement used for lengths in fiber projects.
  class Length < Measurement
    # Canonical unit used for internal length conversion.
    BASE_UNIT = :millimeters

    # Supported length units mapped to millimeter conversion factors.
    FACTORS = {
      millimeters: 1,
      centimeters: 10,
      meters: 1000,
      inches: 25.4,
      feet: 304.8,
      yards: 914.4
    }
  end
end
