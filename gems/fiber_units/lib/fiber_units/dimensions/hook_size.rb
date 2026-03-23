module FiberUnits
  # Represents a crochet hook size with conversion between US and metric systems.
  #
  # Hook sizes use discrete lookup tables rather than linear conversion factors,
  # since the relationship between sizing systems is not proportional.
  # US crochet hook sizes use letter/number designations (e.g. "H/8").
  #
  # @example
  #   hook = FiberUnits::HookSize.new(5.0, :mm)
  #   hook.to(:us)  # => US H/8 hook
  class HookSize
    include Comparable

    # Standard crochet hook size mappings across systems.
    SIZES = [
      {mm: 2.25,  us: "B/1"},
      {mm: 2.75,  us: "C/2"},
      {mm: 3.25,  us: "D/3"},
      {mm: 3.5,   us: "E/4"},
      {mm: 3.75,  us: "F/5"},
      {mm: 4.0,   us: "G/6"},
      {mm: 5.0,   us: "H/8"},
      {mm: 5.5,   us: "I/9"},
      {mm: 6.0,   us: "J/10"},
      {mm: 6.5,   us: "K/10.5"},
      {mm: 8.0,   us: "L/11"},
      {mm: 9.0,   us: "M/N/13"},
      {mm: 10.0,  us: "N/P/15"},
      {mm: 15.0,  us: "P/Q"},
      {mm: 16.0,  us: "Q"},
      {mm: 19.0,  us: "S"}
    ].freeze

    SYSTEMS = %i[mm us].freeze

    attr_reader :value, :system

    # @param value [Numeric, String] the size value in the given system
    # @param system [Symbol] one of :mm or :us
    # @raise [FiberUnits::InvalidUnitError] if the system is unknown or the value is not found
    def initialize(value, system)
      raise FiberUnits::InvalidUnitError, "Unknown hook size system: #{system}" unless SYSTEMS.include?(system)

      @value = value
      @system = system
      @entry = find_entry(value, system)
      freeze
    end

    # Convert this hook size to another sizing system.
    #
    # @param target_system [Symbol] one of :mm or :us
    # @return [HookSize]
    # @raise [FiberUnits::InvalidUnitError] if no equivalent exists in the target system
    def to(target_system)
      raise FiberUnits::InvalidUnitError, "Unknown hook size system: #{target_system}" unless SYSTEMS.include?(target_system)

      target_value = @entry[target_system]
      raise FiberUnits::InvalidUnitError, "No #{target_system} equivalent for #{self}" if target_value.nil?

      self.class.new(target_value, target_system)
    end

    # The metric (mm) value for this hook size.
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
      when :mm then "#{value}mm hook"
      when :us then "US #{value} hook"
      end
    end

    # @return [String]
    def inspect
      "#<#{self.class} #{self}>"
    end

    private

    def find_entry(value, system)
      entry = SIZES.find { |s| s[system] == value }
      raise FiberUnits::InvalidUnitError, "Unknown #{system} hook size: #{value}" unless entry

      entry
    end
  end
end
