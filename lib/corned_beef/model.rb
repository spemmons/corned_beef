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
        serialize @corned_beef_hash_alias,Hash

        class_eval %[def #{attribute}; corned_beef_hash; end]
        class_eval %[def #{attribute}=(value); self.corned_beef_hash = value; end]

        after_initialize :update_corned_beef_hash
        before_validation :update_corned_beef_hash

        ::ActiveRecord::AttributeMethods::Dirty.class_eval do
          def corned_beef_hashes
            respond_to?(:corned_beef_hash_alias) ? [corned_beef_hash_alias.to_s] : []
          end

          def update(*)
            if partial_updates?
              super(changed | ((attributes.keys & self.class.serialized_attributes.keys) - corned_beef_hashes))
            else
              # :nocov: add a test when we know how this can happen...
              super
              # :nocov:
            end
          end
        end

        ::ActiveRecord::Timestamp.class_eval do
          def corned_beef_hashes
            respond_to?(:corned_beef_hash_alias) ? [corned_beef_hash_alias.to_s] : []
          end

          def should_record_timestamps?
            self.record_timestamps && (!partial_updates? || changed? || ((attributes.keys & self.class.serialized_attributes.keys) - corned_beef_hashes).present?)
          end
        end
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
        case @corned_beef_hash = read_attribute(corned_beef_hash_alias)
          when ActiveSupport::HashWithIndifferentAccess
            # do nothing
          when Hash
            @corned_beef_hash = @corned_beef_hash.with_indifferent_access
          when nil
            @corned_beef_hash = {}.with_indifferent_access
          else
            # :nocov: add a test when we know how this can happen...
            raise "corned_beef_hash must be Hash but is #{@corned_beef_hash.class}"
          # :nocov:
        end
        @original_corned_beef_hash = YAML.load(@corned_beef_hash.to_yaml)
      end
      @corned_beef_hash
    end

    def corned_beef_hash=(hash)
      @corned_beef_hash = hash.dup.with_indifferent_access
      (@corned_beef_hash.keys & self.class.columns.collect(&:name)).each {|column_name| eval %[self.#{column_name} = @corned_beef_hash.delete(column_name)]}
      self.class.corned_beef_defaults.each{|attribute,default_value| @corned_beef_hash.delete(attribute) if @corned_beef_hash[attribute] == default_value}

      if @original_corned_beef_hash != (clean_hash = YAML.load(@corned_beef_hash.to_yaml))
        write_attribute(corned_beef_hash_alias,clean_hash)
        @corned_beef_hash = nil
      end

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
      self.corned_beef_hash = corned_beef_hash
    end

  end

end
