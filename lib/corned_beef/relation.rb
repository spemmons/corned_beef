module CornedBeef

  module Relation
    extend ActiveSupport::Concern

    def corned_beef_find(hash)
      self.detect{|record| record.corned_beef_matches?(hash)}
    end

    def corned_beef_where(hash)
      self.select{|record| record.corned_beef_matches?(hash)}
    end

  end

end

require 'active_support/core_ext' # needed to load ActiveRecord::Relation at this point...

class << ActiveRecord::Base; delegate :corned_beef_find,:corned_beef_where,to: :scoped; end

ActiveRecord::Relation.send :include,CornedBeef::Relation