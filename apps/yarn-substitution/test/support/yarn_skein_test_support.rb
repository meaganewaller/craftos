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
