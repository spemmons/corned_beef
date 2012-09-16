module CornedBeef

  module Conversions

    SUPPORTED_CONVERSIONS = [:integer,:float,:string,:array,:hash]

    def Object.corned_beef_conversion_method; :as_is; end
    def Integer.corned_beef_conversion_method; :as_integer; end
    def Float.corned_beef_conversion_method; :as_float; end
    def String.corned_beef_conversion_method; :as_string; end
    def Symbol.corned_beef_conversion_method; :as_string; end
    def Array.corned_beef_conversion_method; :as_array; end
    def Hash.corned_beef_conversion_method; :as_hash; end
    
    def self.conversion_method_for_type(type)
      case type
        when nil
          :as_is
        when Class
          type.corned_beef_conversion_method
        else
          type.to_s.titleize.constantize.corned_beef_conversion_method
      end
    rescue
      raise "invalid type specifier: #{type}"
    end

    def self.as_is(value)
      value
    end

    def self.as_integer(value)
      value.to_i
    rescue
      0
    end

    def self.as_float(value)
      value.to_f
    rescue
      0.0
    end

    def self.as_string(value)
      value.to_s
    end

    def self.as_array(value)
      Array(value)
    end

    def self.as_hash(value)
      value.kind_of?(Hash) ? value : {}
    end

  end

end