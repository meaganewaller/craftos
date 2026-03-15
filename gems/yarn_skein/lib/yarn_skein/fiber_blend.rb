module YarnSkein
  # Represents the fiber composition of a yarn as percentages by fiber type.
  class FiberBlend
    attr_reader :fibers

    # @param fibers [Hash{Symbol => Numeric}] percentages keyed by fiber name
    # @raise [ArgumentError] if the percentages do not sum to 100
    def initialize(fibers)
      total = fibers.values.sum

      unless total == 100
        raise ArgumentError, "Fiber percentages must sum to 100, but got #{total}"
      end

      @fibers = fibers
    end

    # Return the percentage for a given fiber, or zero if it is absent.
    #
    # @param fiber [Symbol]
    # @return [Numeric]
    def percentage(fiber)
      fibers[fiber] || 0
    end

    # Check whether the blend contains a specific fiber.
    #
    # @param fiber [Symbol]
    # @return [Boolean]
    def contains?(fiber)
      fibers.key?(fiber)
    end
  end
end
