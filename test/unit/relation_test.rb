require 'test_helper'

module CornedBeef

  class RelationTest < ActiveSupport::TestCase

    setup do
      DatabaseTester.delete_all
    end

    should 'use corned_beef_find and corned_beef_where to query a subset of matches' do

      assert_difference 'DatabaseTester.count',100 do
        100.times {|counter| DatabaseTester.create(field_integer: counter / 10,extras: {extra_integer: counter % 10,extra_string: "counter_#{counter}"})}
      end

      10.times do |offset|
        assert_equal 10,(result = DatabaseTester.corned_beef_where(extra_integer: offset)).length
        assert_equal (0..9).to_a,result.collect(&:field_integer)

        assert_not_nil result = DatabaseTester.corned_beef_find(extra_integer: offset)
        assert_equal 0,result.field_integer

        assert_equal 1,DatabaseTester.where(field_integer: offset).corned_beef_where(extra_integer: offset).length

        assert_not_nil result = DatabaseTester.where(field_integer: offset).corned_beef_find(extra_integer: offset)
        assert_equal offset,result.field_integer
      end

      100.times do |counter|
        string = "counter_#{counter}"
        assert_equal 1,(result = DatabaseTester.corned_beef_where(extra_string: string)).length
        assert_equal string,result[0].extra_string
      end

    end

  end

end