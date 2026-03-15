module FiberUnits
  # A weight measurement used for yarn and fiber quantities.
  class Weight < Measurement
    # Supported weight units mapped to gram conversion factors.
    FACTORS = {
      grams: 1.0,
      kilograms: 1000.0,
      ounces: 28.3495,
      pounds: 453.592
    }.freeze
  end
end
