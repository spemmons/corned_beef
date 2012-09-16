require 'test_helper'

module CornedBeef

  class AttributesTest < ActiveSupport::TestCase

    setup do
      class AttributeTester; include CornedBeef::Attributes; end
    end

    should 'throw an error if included after CornedBeef::Model' do

      error = assert_raises(RuntimeError) do
        class ModelErrorTest < ActiveRecord::Base
          set_table_name :database_testers
          include Model
          include Attributes
        end
      end
      assert_equal 'CornedBeef::Model already defined - including CornedBeef::Attributes not required',error.message

    end

    should 'throw an error if included after CornedBeef::Seeds' do

      error = assert_raises(RuntimeError) do
        class SeedsErrorTest < ActiveRecord::Base
          set_table_name :database_testers
          include Seeds
          include Attributes
        end
      end
      assert_equal 'CornedBeef::Model already defined - including CornedBeef::Attributes not required',error.message

    end

    should 'support defining accessors' do
      AttributeTester.corned_beef_accessor :accessor
      assert_equal %w(accessor),AttributeTester.corned_beef_attributes

      tester = AttributeTester.new
      assert_nil tester.accessor
      assert_nil tester.default_accessor

      tester.accessor = 123
      assert_equal 123,tester.accessor
    end

    [:integer,:float,:string].each do |type|
      context "for #{type} types" do
        should "support specifying #{type} accessors" do
          AttributeTester.corned_beef_accessor type,type: type,default: 1,required: true
          assert AttributeTester.corned_beef_attributes.include?(type.to_s)
          assert_equal "as_#{type}",(conversion_method = Conversions.conversion_method_for_type(type)).to_s

          default_value = Conversions.send conversion_method,1
          tester = AttributeTester.new
          assert_equal default_value,tester.send(type)
          assert_equal default_value,tester.send("default_#{type}")
          assert_equal ({}),tester.corned_beef_hash

          assigned_value = Conversions.send conversion_method,2
          eval "tester.#{type} = 2"
          assert_equal assigned_value,tester.send(type)
          assert_equal assigned_value,tester.corned_beef_get_attribute(type)
          assert_equal ({type.to_s => 2}),tester.corned_beef_hash

          assigned_value = Conversions.send conversion_method,3
          tester.corned_beef_set_attribute(type,3)
          assert_equal assigned_value,tester.send(type)
          assert_equal assigned_value,tester.corned_beef_get_attribute(type)
          assert_equal ({type.to_s => 3}),tester.corned_beef_hash

          assigned_value = Conversions.send conversion_method,4
          tester.corned_beef_set_attributes(type => 4)
          assert_equal assigned_value,tester.send(type)
          assert_equal assigned_value,tester.corned_beef_get_attribute(type)
          assert_equal ({type.to_s => 4}),tester.corned_beef_hash

          assigned_value = Conversions.send conversion_method,5
          tester.corned_beef_hash = {type => 5}
          assert_equal assigned_value,tester.send(type)
          assert_equal assigned_value,tester.corned_beef_get_attribute(type)
          assert_equal ({type.to_s => 5}),tester.corned_beef_hash

          eval "tester.#{type} = nil"
          assert_equal default_value,tester.send(type)
        end
      end
    end

  end

end
