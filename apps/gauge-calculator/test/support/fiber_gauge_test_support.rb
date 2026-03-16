unless defined?(FiberGauge)
  module FiberGauge
  end
end

unless defined?(FiberGauge::Gauge)
  class FiberGauge::Gauge
  end
end

class TestLength
  attr_reader :value, :unit

  def initialize(value, unit)
    @value = value
    @unit = unit
  end
end

class TestCount
  attr_reader :value, :kind

  def initialize(value, kind)
    @value = value
    @kind = kind
  end
end

module GaugeNumericTestExtensions
  def stitches
    TestCount.new(self, :stitches)
  end

  def rows
    TestCount.new(self, :rows)
  end

  def inches
    TestLength.new(self, :inches)
  end

  def centimeters
    TestLength.new(self, :centimeters)
  end
end

Integer.include(GaugeNumericTestExtensions) unless Integer.method_defined?(:stitches)
Integer.include(GaugeNumericTestExtensions) unless Integer.method_defined?(:rows)
Float.include(GaugeNumericTestExtensions) unless Float.method_defined?(:inches)
Float.include(GaugeNumericTestExtensions) unless Float.method_defined?(:centimeters)

module ClassMethodStubHelper
  def stub_class_method(klass, method_name, callable)
    singleton = class << klass
      self
    end

    original_method = singleton.instance_method(method_name)
    singleton.define_method(method_name, &callable)

    yield
  ensure
    singleton.define_method(method_name, original_method)
  end
end
