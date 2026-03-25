# frozen_string_literal: true

module FiberPattern
  # Combines body measurements with ease to produce finished garment dimensions.
  #
  # @example
  #   body = FiberPattern::BodyMeasurements.new(bust: 36.inches, waist: 30.inches)
  #   ease = FiberPattern::Ease.new(bust: 4.inches, waist: 2.inches)
  #   garment = FiberPattern::GarmentSizing.new(body: body, ease: ease)
  #   garment.bust   # => 40.inches
  #   garment.waist  # => 32.inches
  class GarmentSizing
    # @return [FiberPattern::BodyMeasurements]
    attr_reader :body

    # @return [FiberPattern::Ease]
    attr_reader :ease

    # @param body [FiberPattern::BodyMeasurements] body measurements
    # @param ease [FiberPattern::Ease] ease preferences
    def initialize(body:, ease:)
      validate!(body, ease)
      @body = body
      @ease = ease
      define_accessors!
    end

    # Returns the finished garment dimension for a given measurement.
    #
    # @param name [Symbol]
    # @return [FiberUnits::Length] body measurement + ease
    # @raise [ArgumentError] if the measurement is not defined
    def dimension(name)
      raise ArgumentError, "unknown measurement #{name.inspect}" unless body.data.key?(name)

      body[name] + (ease[name] || zero_length(body[name]))
    end

    # Hash-style access to finished dimensions.
    #
    # @param name [Symbol]
    # @return [FiberUnits::Length]
    def [](name)
      dimension(name)
    end

    # Returns all finished garment dimensions.
    #
    # @return [Hash<Symbol, FiberUnits::Length>]
    def dimensions
      body.measurements.each_with_object({}) do |name, result|
        result[name] = dimension(name)
      end
    end

    private

    def validate!(body, ease)
      ease.measurements.each do |name|
        unless body.measurements.include?(name)
          raise ArgumentError, "ease defines #{name.inspect} but body measurements does not"
        end
      end
    end

    def define_accessors!
      body.measurements.each do |name|
        define_singleton_method(name) { dimension(name) }
      end
    end

    def zero_length(reference)
      reference * 0
    end
  end
end
