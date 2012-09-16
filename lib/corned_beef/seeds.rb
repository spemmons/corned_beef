require 'rails'

module CornedBeef

  module Seeds

    def self.included(base)
      base.send :include,Model unless base.respond_to?(:corned_beef_hash_alias)
      base.extend ClassMethods
    end

    module ClassMethods

      def seed_yaml_file
        Rails.root + "config/#{name.underscore}.yml"
      end

      def seed_attribute_sets
        YAML::load_file(seed_yaml_file)
      end

      def reset_seeds
        delete_all
        seed_attribute_sets.each do |attributes|
          seed = new
          seed.corned_beef_hash = attributes
          seed.save!
        end
      end

    end

  end

end