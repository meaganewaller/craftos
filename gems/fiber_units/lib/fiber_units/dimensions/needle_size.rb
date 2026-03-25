module FiberUnits
  # Represents a knitting needle size with conversion between US, metric, and UK systems.
  #
  # Needle sizes use discrete lookup tables rather than linear conversion factors,
  # since the relationship between sizing systems is not proportional.
  #
  # @example
  #   needle = FiberUnits::NeedleSize.new(8, :us)
  #   needle.to(:mm)   # => 5.0mm needle
  #   needle.to(:uk)   # => UK 6 needle
  class NeedleSize
    include Comparable

    # Standard knitting needle size mappings across systems.
    # Not all sizes exist in every system — nil indicates no equivalent.
    SIZES = [
      {mm: 2.0,  us: 0,    uk: 14},
      {mm: 2.25, us: 1,    uk: 13},
      {mm: 2.75, us: 2,    uk: 12},
      {mm: 3.0,  us: 2.5,  uk: 11},
      {mm: 3.25, us: 3,    uk: 10},
      {mm: 3.5,  us: 4,    uk: nil},
      {mm: 3.75, us: 5,    uk: 9},
      {mm: 4.0,  us: 6,    uk: 8},
      {mm: 4.5,  us: 7,    uk: 7},
      {mm: 5.0,  us: 8,    uk: 6},
      {mm: 5.5,  us: 9,    uk: 5},
      {mm: 6.0,  us: 10,   uk: 4},
      {mm: 6.5,  us: 10.5, uk: 3},
      {mm: 7.0,  us: nil,  uk: 2},
      {mm: 7.5,  us: nil,  uk: 1},
      {mm: 8.0,  us: 11,   uk: 0},
      {mm: 9.0,  us: 13,   uk: nil},
      {mm: 10.0, us: 15,   uk: nil},
      {mm: 12.0, us: 17,   uk: nil},
      {mm: 15.0, us: 19,   uk: nil},
      {mm: 19.0, us: 35,   uk: nil},
      {mm: 20.0, us: 36,   uk: nil},
      {mm: 25.0, us: 50,   uk: nil}
    ].map(&:freeze).freeze

    SYSTEMS = %i[mm us uk].freeze

    attr_reader :value, :system

    # @param value [Numeric] the size value in the given system
    # @param system [Symbol] one of :mm, :us, or :uk
    # @raise [FiberUnits::InvalidUnitError] if the system is unknown or the value is not found
    def initialize(value, system)
      raise FiberUnits::InvalidUnitError, "Unknown needle size system: #{system}" unless SYSTEMS.include?(system)

      @value = value
      @system = system
      @entry = find_entry(value, system)
      freeze
    end

    # Convert this needle size to another sizing system.
    #
    # @param target_system [Symbol] one of :mm, :us, or :uk
    # @return [NeedleSize]
    # @raise [FiberUnits::InvalidUnitError] if no equivalent exists in the target system
    def to(target_system)
      raise FiberUnits::InvalidUnitError, "Unknown needle size system: #{target_system}" unless SYSTEMS.include?(target_system)

      target_value = @entry[target_system]
      raise FiberUnits::InvalidUnitError, "No #{target_system} equivalent for #{self}" if target_value.nil?

      self.class.new(target_value, target_system)
    end

    # The metric (mm) value for this needle size.
    #
    # @return [Numeric]
    def to_mm
      @entry[:mm]
    end

    # @return [-1, 0, 1, nil]
    def <=>(other)
      return nil unless other.is_a?(self.class)

      to_mm <=> other.to_mm
    end

    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) && to_mm == other.to_mm
    end

    # @return [String]
    def to_s
      case system
      when :mm then "#{value}mm needle"
      when :us then "US #{value} needle"
      when :uk then "UK #{value} needle"
      end
    end

    # @return [String]
    def inspect
      "#<#{self.class} #{self}>"
    end

    private

    def find_entry(value, system)
      entry = SIZES.find { |s| s[system] == value }
      raise FiberUnits::InvalidUnitError, "Unknown #{system} needle size: #{value}" unless entry

      entry
    end
  end
end
