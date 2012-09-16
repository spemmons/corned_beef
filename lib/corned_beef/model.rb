module CornedBeef

  module Model

    def self.included(base)
      base.send :include,Attributes unless base.respond_to?(:corned_beef_attributes)
      base.extend ClassMethods
      base.send :include,InstanceMethods
    end

    module ClassMethods

      def corned_beef_hash_alias
        @corned_beef_hash_alias
      end

      def set_corned_beef_hash_alias(attribute)
        @corned_beef_hash_alias = attribute.to_sym
        serialize @corned_beef_hash_alias,Hash

        class_eval %[def #{attribute}; corned_beef_hash; end]

        before_validation :update_corned_beef_hash
      end

    end

    module InstanceMethods

      def initialize(attributes = nil)
        super(attributes)
        valid?
      end

      def corned_beef_matches?(hash)
        !hash.detect{|pair| corned_beef_get_attribute(pair.first) != pair.last}
      end

      def corned_beef_hash_alias
        self.class.corned_beef_hash_alias || raise('no corned_beef_hash_alias defined')
      end

      def corned_beef_hash
        self.corned_beef_hash = result = {} unless result = read_attribute(corned_beef_hash_alias)
        result.with_indifferent_access
      end

      def corned_beef_hash=(hash)
        hash = hash.dup.with_indifferent_access
        (hash.keys & self.class.columns.collect(&:name)).each {|column_name| eval %[self.#{column_name} = hash.delete(column_name)]}
        eval %[self.#{corned_beef_hash_alias} = hash]
        super(hash)
      end

      def to_hash
        (non_corned_beef_hash = attributes.dup).delete(corned_beef_hash_alias.to_s)
        corned_beef_hash.merge(non_corned_beef_hash)
      end

      def to_json
        to_hash.to_json
      end

      def to_yaml
        to_hash.to_yaml
      end

    private

      def update_corned_beef_hash
        self.corned_beef_hash = corned_beef_hash if changed_attributes.include?(corned_beef_hash_alias.to_s)
      end

    end

  end

end