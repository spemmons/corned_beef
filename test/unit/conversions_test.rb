require 'test_helper'

module CornedBeef

  class ConversionsTest < ActiveSupport::TestCase

    should 'have a conversion method for every class' do
      assert_equal :as_is,      Object.corned_beef_conversion_method
      assert_equal :as_is,      Rational.corned_beef_conversion_method
      assert_equal :as_is,      Time.corned_beef_conversion_method
      assert_equal :as_is,      nil.class.corned_beef_conversion_method
      assert_equal :as_is,      true.class.corned_beef_conversion_method
      assert_equal :as_is,      false.class.corned_beef_conversion_method

      assert_equal :as_integer, Integer.corned_beef_conversion_method
      assert_equal :as_integer, Fixnum.corned_beef_conversion_method
      assert_equal :as_integer, Bignum.corned_beef_conversion_method

      assert_equal :as_float,   Float.corned_beef_conversion_method

      assert_equal :as_string,  String.corned_beef_conversion_method
      assert_equal :as_string,  Symbol.corned_beef_conversion_method

      assert_equal :as_array,   Array.corned_beef_conversion_method

      assert_equal :as_hash,    Hash.corned_beef_conversion_method
    end

    should 'not have a conversion method for modules' do
      assert_raises(NoMethodError){ Kernel.corned_beef_conversion_method  }
    end
    
    should 'find as_is for nil' do
      assert_equal :as_is,Conversions.conversion_method_for_type(nil)
    end
    
    should 'find as_integer for Integer or integer symbol' do
      assert_equal :as_integer,Conversions.conversion_method_for_type(Integer)
      assert_equal :as_integer,Conversions.conversion_method_for_type(:integer)
    end
    
    should 'find as_float for Float or float symbol' do
      assert_equal :as_float,Conversions.conversion_method_for_type(Float)
      assert_equal :as_float,Conversions.conversion_method_for_type(:float)
    end
    
    should 'find as_string for String or string symbol' do
      assert_equal :as_string,Conversions.conversion_method_for_type(String)
      assert_equal :as_string,Conversions.conversion_method_for_type(:string)
    end
    
    should 'find as_array for Array or array symbol' do
      assert_equal :as_array,Conversions.conversion_method_for_type(Array)
      assert_equal :as_array,Conversions.conversion_method_for_type(:array)
    end
    
    should 'find as_hash for Hash or hash symbol' do
      assert_equal :as_hash,Conversions.conversion_method_for_type(Hash)
      assert_equal :as_hash,Conversions.conversion_method_for_type(:hash)
    end

    should 'throw an error when trying to find something that is not a class' do
      error = assert_raises(RuntimeError){ Conversions.conversion_method_for_type(Kernel) }
      assert_equal error.message,'invalid type specifier: Kernel'
      error = assert_raises(RuntimeError){ Conversions.conversion_method_for_type(:kernel) }
      assert_equal error.message,'invalid type specifier: kernel'
      error = assert_raises(RuntimeError){ Conversions.conversion_method_for_type(true) }
      assert_equal error.message,'invalid type specifier: true'
      error = assert_raises(RuntimeError){ Conversions.conversion_method_for_type(1) }
      assert_equal error.message,'invalid type specifier: 1'
    end

    context 'value collection' do

      def setup
        @values = [
          nil,
          true,
          false,
          1,
          1.0,
          'abc',
          :abc,
          [1,2,3],
          {abc: 1},
        ]
      end

      should 'remain as_is' do
        assert_equal @values,@values.collect{|value| Conversions.as_is(value)}
      end

      should 'become integers' do
        assert_equal [
            0,
            0,
            0,
            1,
            1,
            0,
            0,
            0,
            0,
          ],@values.collect{|value| Conversions.as_integer(value)}
      end

      should 'become floats' do
        assert_equal [
            0.0,
            0.0,
            0.0,
            1.0,
            1.0,
            0.0,
            0.0,
            0.0,
            0.0,
          ],@values.collect{|value| Conversions.as_float(value)}
      end

      should 'become strings' do
        assert_equal [
            '',
            'true',
            'false',
            '1',
            '1.0',
            'abc',
            'abc',
            '[1, 2, 3]',
            '{:abc=>1}',
          ],@values.collect{|value| Conversions.as_string(value)}
      end

      should 'become arrays' do
        assert_equal [
            [],
            [true],
            [false],
            [1],
            [1.0],
            ['abc'],
            [:abc],
            [1,2,3],
            [[:abc, 1]],
          ],@values.collect{|value| Conversions.as_array(value)}
      end

      should 'become hashs' do
        assert_equal [
            {},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
            {abc: 1},
          ],@values.collect{|value| Conversions.as_hash(value)}
      end

    end

  end

end
