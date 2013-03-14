module CornedBeef

  module Model
    extend ActiveSupport::Concern

    include Attributes unless respond_to?(:corned_beef_attributes)

    module ClassMethods

      def corned_beef_hash_alias
        @corned_beef_hash_alias
      end

      def set_corned_beef_hash_alias(attribute)
        @corned_beef_hash_alias = attribute.to_sym

        class_eval %[def #{attribute}; corned_beef_hash; end]
        class_eval %[def #{attribute}=(value); self.corned_beef_hash = value; end]

        before_validation :update_corned_beef_hash
      end

    end

    def corned_beef_matches?(hash)
      !hash.detect{|pair| corned_beef_get_attribute(pair.first) != pair.last}
    end

    def corned_beef_hash_alias
      self.class.corned_beef_hash_alias || raise('no corned_beef_hash_alias defined')
    end

    def corned_beef_hash
      unless @corned_beef_hash
        current_yaml = read_attribute(corned_beef_hash_alias) || '--- {}'
        @corned_beef_hash = YAML.load(current_yaml).with_indifferent_access
        @original_corned_beef_hash = YAML.load(current_yaml)
      end
      @corned_beef_hash
    end

    def corned_beef_hash=(hash)
      raise 'corned_beef_hash must be a kind of Hash' unless (hash = (hash || {}).dup.with_indifferent_access).kind_of?(Hash)

      (hash.keys & self.class.columns.collect(&:name)).each {|column_name| eval %[self.#{column_name} = hash.delete(column_name)]}
      self.class.corned_beef_defaults.each{|attribute,default_value| hash.delete(attribute) if hash[attribute] == default_value}

      return @corned_beef_hash if @original_corned_beef_hash == YAML.load(persisted_yaml = hash.to_yaml)

      write_attribute(corned_beef_hash_alias,persisted_yaml)
      raise 'corned_beef_hash should be changed' unless changes[corned_beef_hash_alias]
      @corned_beef_hash = nil
      corned_beef_hash
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

    def update_corned_beef_hash
      self.corned_beef_hash = @corned_beef_hash if @corned_beef_hash
    end

  end

end
