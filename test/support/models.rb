ActiveRecord::Schema.define do 
  create_table  :database_testers do |t|
    t.integer   :field_integer
    t.float     :field_float
    t.string    :field_string
    t.integer   :field_true
    t.integer   :field_false
    t.text      :extras
  end

  create_table  :time_testers do |t|
    t.text      :extras
    t.timestamps
  end
end

# Pseudo models for testing purposes

class DatabaseTester < ActiveRecord::Base
  include CornedBeef::Model

  set_corned_beef_hash_alias    :extras
  
  corned_beef_integer_accessor  :extra_integer
  corned_beef_float_accessor    :extra_float
  corned_beef_string_accessor   :extra_string
  corned_beef_boolean_accessor  :extra_true
  corned_beef_boolean_accessor  :extra_false
  corned_beef_array_accessor    :extra_array
  corned_beef_hash_accessor     :extra_hash

  validates_format_of :extra_string, :message => 'may not have uppercase letters', :with => /^[^A-Z]*$/
end

class TimeTester < ActiveRecord::Base
  include CornedBeef::Model

  set_corned_beef_hash_alias    :extras
end
