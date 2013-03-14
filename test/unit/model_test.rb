require 'test_helper'

module CornedBeef

  class ModelTest < ActiveSupport::TestCase

    setup do
      DatabaseTester.delete_all

      @fields = {
        id:             123,
        field_integer:  1,
        field_float:    2.0,
        field_true:     nil,
        field_false:    nil,
        field_string:   'field',
      }
      @nine_ten = {nine: 9,ten: 10}
      @extras = {
          extra_integer:  3,
          extra_float:    4.0,
          extra_true:     true,
          extra_false:    false,
          extra_string:   'extra',
          extra_array:    [5,6,7],
          extra_hash:     @nine_ten,
          extra_other:    'other',
      }
    end

    should 'put attributes in their proper places' do
      assert_nothing_raised do
        attributes = @fields.merge(@extras)

        tester1 = DatabaseTester.new
        tester1.corned_beef_hash = attributes
        assert_equal @extras.dup.with_indifferent_access,tester1.extras

        tester2 = DatabaseTester.new
        tester2.extras = attributes
        assert_equal @extras.dup.with_indifferent_access,tester2.extras

        tester3 = DatabaseTester.new(extras: attributes)
        assert_equal @extras.dup.with_indifferent_access,tester3.extras

        [tester1,tester2,tester3].each do |tester|
          2.times do
            assert_equal 123,     tester.id
            assert_equal 1,       tester.field_integer
            assert_equal 2.0,     tester.field_float
            assert_equal nil,    tester.field_true
            assert_equal nil,   tester.field_false
            assert_equal 'field', tester.field_string
            assert_equal 3,       tester.extra_integer
            assert_equal 4.0,     tester.extra_float
            assert_equal true,    tester.extra_true
            assert_equal false,   tester.extra_false
            assert_equal 'extra', tester.extra_string
            assert_equal [5,6,7], tester.extra_array
            assert_equal 'other', tester.extras[:extra_other]
            assert_equal @nine_ten.dup.with_indifferent_access,tester.extra_hash
            assert_equal @extras.dup.with_indifferent_access,tester.extras

            assert tester.save

            assert_not_nil tester = DatabaseTester.find_by_id(tester.id)
          end

          tester.destroy
        end

      end
    end

    should 'match corned_beef_hash values' do
      tester = DatabaseTester.new(extras: {extra_integer: 1,extra_true: true,extra_false: false,extra_string: 'extra',extra_array: [1,2,3],extra_hash: {test: 4}})

      assert tester.corned_beef_matches?(extra_integer: 1)
      assert tester.corned_beef_matches?(extra_true: true)
      assert tester.corned_beef_matches?(extra_false: false)
      assert tester.corned_beef_matches?(extra_string: 'extra')
      assert tester.corned_beef_matches?(extra_array: [1,2,3])
      assert tester.corned_beef_matches?(extra_hash: {'test' => 4})
      assert tester.corned_beef_matches?(extra_integer: 1,extra_string: 'extra',extra_array: [1,2,3],extra_hash: {'test' => 4})

      assert !tester.corned_beef_matches?(extra_integer: 10)
      assert !tester.corned_beef_matches?(extra_string: 'extra0')
      assert !tester.corned_beef_matches?(extra_array: [1,2,3,0])
      assert !tester.corned_beef_matches?(extra_hash: {'test' => 40})
      assert !tester.corned_beef_matches?(extra_integer: 1,extra_string: 'extra',extra_array: [1,2,3],extra_hash: {'test' => 4},unknown: 'X')
    end

    should 'convert to hash json and yaml' do
      attributes = @fields.merge(@extras)
      tester = DatabaseTester.new(extras: attributes)

      2.times do |pass_number|
        assert_equal attributes.dup.with_indifferent_access,tester.to_hash,"PASS: #{pass_number}"

        assert tester.save

        assert_not_nil(tester = DatabaseTester.find_by_id(tester.id),"PASS: #{pass_number}")
      end
    end

    should 'throw an error without corned_beef_hash_alias' do

      class AliasErrorTest < ActiveRecord::Base
        set_table_name :database_testers
        include Model
      end

      assert_nil AliasErrorTest.corned_beef_hash_alias
      error = assert_raises(RuntimeError) { AliasErrorTest.new.corned_beef_hash_alias}
      assert_equal 'no corned_beef_hash_alias defined',error.message

    end

    should 'set attributes and save their values' do

      tester = DatabaseTester.new
      assert_nil tester.extra_integer

      tester.extra_integer = 1
      assert_equal 1,tester.extra_integer
      assert_equal [],tester.changed
      assert tester.valid?
      assert_equal %w(extras),tester.changed
      assert tester.save
      assert_equal "---\nextra_integer: 1\n",DatabaseTester.connection.select_value("select extras from #{DatabaseTester.table_name} where id = #{tester.id}")

      tester = DatabaseTester.find tester.id
      assert_equal 1,tester.extra_integer
      assert_equal [],tester.changed
      assert tester.valid?
      assert_equal [],tester.changed
      assert tester.save

      tester.extra_integer = 2
      assert_equal 2,tester.extra_integer
      assert_equal [],tester.changed
      assert tester.valid?
      assert_equal %w(extras),tester.changed
      assert tester.save
      assert_equal "---\nextra_integer: 2\n",DatabaseTester.connection.select_value("select extras from #{DatabaseTester.table_name} where id = #{tester.id}")

      tester = DatabaseTester.find tester.id
      assert_equal 2,tester.extra_integer
      assert_equal [],tester.changed
      assert tester.valid?
      assert_equal [],tester.changed
      assert tester.save

    end

    should 'not update the database if no changes to the corned_beef_hash are made' do

      explicit_time = Time.utc_time(2000,1,1)
      tester = TimeTester.new
      tester.updated_at = explicit_time
      assert tester.save
      assert_equal "--- {}\n",DatabaseTester.connection.select_value("select extras from #{TimeTester.table_name} where id = #{tester.id}")
      assert_equal explicit_time,tester.updated_at

      # no change
      assert tester.save
      assert_equal "--- {}\n",DatabaseTester.connection.select_value("select extras from #{TimeTester.table_name} where id = #{tester.id}")
      assert_equal explicit_time,tester.updated_at

      tester.extras['test'] = 1
      assert tester.save
      assert_equal "---\ntest: 1\n",DatabaseTester.connection.select_value("select extras from #{TimeTester.table_name} where id = #{tester.id}")
      assert_not_equal explicit_time,tester.updated_at

      # reset timestamp
      tester.updated_at = explicit_time
      assert tester.save
      assert_equal "---\ntest: 1\n",DatabaseTester.connection.select_value("select extras from #{TimeTester.table_name} where id = #{tester.id}")
      assert_equal explicit_time,tester.updated_at

      # no change
      assert tester.save
      assert_equal "---\ntest: 1\n",DatabaseTester.connection.select_value("select extras from #{TimeTester.table_name} where id = #{tester.id}")
      assert_equal explicit_time,tester.updated_at

    end

    should 'ensure that 2nd level changes to a hash are captured' do
      tester = DatabaseTester.new
      assert_equal ({}),tester.corned_beef_hash
      assert_equal ({}),tester.extras

      tester.corned_beef_hash[:level1A] = 'A'
      assert tester.save

      tester = DatabaseTester.find tester.id
      assert_equal ({'level1A' => 'A'}),tester.corned_beef_hash
      assert_equal ({'level1A' => 'A'}),tester.extras

      tester.extras[:level1B] = 'B'
      assert tester.save

      tester = DatabaseTester.find tester.id
      assert_equal ({'level1A' => 'A','level1B' => 'B'}),tester.corned_beef_hash
      assert_equal ({'level1A' => 'A','level1B' => 'B'}),tester.extras

      tester.corned_beef_hash[:level1A] = {level2A: 'C'}
      assert tester.save

      tester = DatabaseTester.find tester.id
      assert_equal ({'level1A' => {'level2A' => 'C'},'level1B' => 'B'}),tester.corned_beef_hash
      assert_equal ({'level1A' => {'level2A' => 'C'},'level1B' => 'B'}),tester.extras
      
      tester.extras[:level1B] = {level2B: 'D'}
      assert tester.save

      tester = DatabaseTester.find tester.id
      assert_equal ({'level1A' => {'level2A' => 'C'},'level1B' => {'level2B' => 'D'}}),tester.corned_beef_hash
      assert_equal ({'level1A' => {'level2A' => 'C'},'level1B' => {'level2B' => 'D'}}),tester.extras

      tester.corned_beef_hash[:level1A][:level2A] = 'E'
      assert tester.save

      tester = DatabaseTester.find tester.id
      assert_equal ({'level1A' => {'level2A' => 'E'},'level1B' => {'level2B' => 'D'}}),tester.corned_beef_hash
      assert_equal ({'level1A' => {'level2A' => 'E'},'level1B' => {'level2B' => 'D'}}),tester.extras

      tester.extras[:level1B][:level2B] = 'F'
      assert tester.save

      tester = DatabaseTester.find tester.id
      assert_equal ({'level1A' => {'level2A' => 'E'},'level1B' => {'level2B' => 'F'}}),tester.corned_beef_hash
      assert_equal ({'level1A' => {'level2A' => 'E'},'level1B' => {'level2B' => 'F'}}),tester.extras
    end

    should 'respect validators' do
      tester = DatabaseTester.new
      assert tester.valid?
      assert_equal [],tester.errors.to_a

      tester.extra_string = 'test'
      assert tester.valid?
      assert_equal [],tester.errors.to_a

      tester.extra_string = 'ABC'
      assert !tester.valid?
      assert_equal ['Extra string may not have uppercase letters'],tester.errors.to_a
    end

  end

end
