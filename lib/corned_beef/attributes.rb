module CornedBeef
  
  module Attributes
    extend ActiveSupport::Concern

    module ClassMethods

      def corned_beef_attribute?(attribute)
        corned_beef_defaults.has_key?(attribute)
      end

      def corned_beef_attributes
        corned_beef_defaults.keys
      end

      [:accessor,:reader].each do |method|
        eval %[def corned_beef_#{method}(attributes,options = {}); Array(attributes).each{|attribute| corned_beef_define_#{method}(attribute.to_s,options[:type],options[:default],options[:required].to_s == 'true')}; end]

        Conversions::SUPPORTED_CONVERSIONS.each {|type| eval %[def corned_beef_#{type}_#{method}(attributes,options = {}); corned_beef_#{method}(attributes,options.merge(type: '#{type}')); end]}
      end

      def corned_beef_defaults
        @corned_beef_defaults ||= {}.with_indifferent_access
      end

    private

      def corned_beef_define_accessor(attribute,type,default_value,required)
        corned_beef_define_reader(attribute,type,default_value,required)

        class_eval %[def #{attribute}=(value); corned_beef_write_attribute('#{attribute}',value); end]
      end

      def corned_beef_define_reader(attribute,type,default_value,required)
        raise "attribute #{attribute} already defined" if corned_beef_attribute?(attribute)

        conversion_method = Conversions.conversion_method_for_type(type)

        corned_beef_defaults[attribute] = (required || !default_value.nil?) ? Conversions.send(conversion_method,default_value) : nil
        class_eval %[def default_#{attribute}; (value = self.class.corned_beef_defaults['#{attribute}']).duplicable? ? value.dup : value; end]
        class_eval %[def #{attribute}; corned_beef_read_attribute('#{attribute}',:#{conversion_method}); end]
        class_eval %[alias_method :#{attribute}?, :#{attribute}] if type.to_s == 'boolean'
      end
    end

    def corned_beef_get_attribute(attribute)
      attribute = attribute.to_s
      self.class.corned_beef_attribute?(attribute) ? send(attribute) : corned_beef_hash[attribute]
    end

    def corned_beef_set_attribute(attribute,value)
      attribute = attribute.to_s
      self.class.corned_beef_attribute?(attribute) ? send("#{attribute}=",value) : (corned_beef_hash[attribute] = value)
    end

    def corned_beef_set_attributes(hash)
      hash.each{|pair| corned_beef_set_attribute(*pair)}
    end

    def corned_beef_hash
      @corned_beef_hash ||= {}.with_indifferent_access
    end

    def corned_beef_hash=(hash)
      @corned_beef_hash = hash && hash.with_indifferent_access
    end

  private

    def corned_beef_read_attribute(attribute,conversion_method)
      (value = corned_beef_hash[attribute]).nil? ? self.send("default_#{attribute}") : Conversions.send(conversion_method,value)
    end

    def corned_beef_write_attribute(attribute,value)
      corned_beef_hash[attribute] = value == self.send("default_#{attribute}") ? nil : value
    end

  end

end