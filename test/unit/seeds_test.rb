require 'test_helper'

module CornedBeef

  class SeedsTest < ActiveSupport::TestCase

    setup do
      DatabaseTester.delete_all
    end

    should 'ensure that seeds are idempotent' do
      
      class ::SeedTest < ActiveRecord::Base
        set_table_name :database_testers

        include Seeds

        set_corned_beef_hash_alias    :extras

        corned_beef_integer_accessor  :extra_integer
        corned_beef_float_accessor    :extra_float
        corned_beef_string_accessor   :extra_string
        corned_beef_array_accessor    :extra_array
        corned_beef_hash_accessor     :extra_hash
      end

      common_seed_tests(SeedTest,2)

    end

    should 'verify that ERB works in a seeds YAML file' do

      class ::ErbTest < ActiveRecord::Base
        set_table_name :database_testers

        include Seeds

        set_corned_beef_hash_alias    :extras

        corned_beef_integer_accessor  :extra_integer
        corned_beef_float_accessor    :extra_float
        corned_beef_string_accessor   :extra_string
        corned_beef_array_accessor    :extra_array
        corned_beef_hash_accessor     :extra_hash
      end

      common_seed_tests(ErbTest,1)

      ErbTest.corned_beef_disable_erb true

      ErbTest.reset_seeds
      tester = ErbTest.find 1
      assert_equal 0,                   tester.field_integer
      assert_equal 0.0,                 tester.field_float
      assert_equal %[<%= 'field_1' %>], tester.field_string
      assert_equal 0,                   tester.extra_integer
      assert_equal 0.0,                 tester.extra_float
      assert_equal %[<%= 'extra_1' %>], tester.extra_string

    end

    def common_seed_tests(model,count)
      assert_difference "#{model}.count",3 do

        count.times do

          model.reset_seeds

          tester = model.find 1
          assert_equal 'field_1',     tester.field_string
          assert_equal 1,             tester.field_integer
          assert_equal 2.0,           tester.field_float
          assert_equal 3,             tester.extra_integer
          assert_equal 4.0,           tester.extra_float
          assert_equal 'extra_1',     tester.extra_string
          assert_equal [1,2,3],       tester.extra_array
          assert_equal ({'one' => 'hash_1','two' => 'hash_2','three' => 'hash_3'}),
                                      tester.extra_hash

          tester = model.find 2
          assert_equal 'field_10',    tester.field_string
          assert_equal 10,            tester.field_integer
          assert_equal 20.0,          tester.field_float
          assert_equal 30,            tester.extra_integer
          assert_equal 40.0,          tester.extra_float
          assert_equal 'extra_10',    tester.extra_string
          assert_equal [10,20,30],    tester.extra_array
          assert_equal ({'one' => 'hash_10','two' => 'hash_20','three' => 'hash_30'}),
                                      tester.extra_hash

          tester = model.find 3
          assert_equal 'field_100',   tester.field_string
          assert_equal 100,           tester.field_integer
          assert_equal 200.0,         tester.field_float
          assert_equal 300,           tester.extra_integer
          assert_equal 400.0,         tester.extra_float
          assert_equal 'extra_100',   tester.extra_string
          assert_equal [100,200,300], tester.extra_array
          assert_equal ({'one' => 'hash_100','two' => 'hash_200','three' => 'hash_300'}),
                                      tester.extra_hash
        end
      end
    end

  end

end