require_relative 'minitest_helper'
require 'hammer-weak'

class WeakTest < MiniTest::Spec
  def gc
    if defined? JRUBY_VERSION
      JRuby.gc
    else
      ObjectSpace.garbage_collect
      ObjectSpace.garbage_collect
    end
  end

  def isolate
    yield
  end

  describe Hammer::Weak::Queue do
    before do
      @queue = Hammer::Weak::Queue.new
      @str   = 'b'
      @queue.push 'a', @str
    end

    it 'should iterate a and b' do
      a = []
      @queue.each { |v| a << v }
      a.size.must_equal 2
    end

    it 'should iterate only b' do
      gc
      a = []
      @queue.each { |v| a << v }
      a.size.must_equal 1
    end

    it 'should drop a and return b' do
      gc
      @queue.pop.must_equal @str
    end
  end

  describe Hammer::Weak::WeakKeyHash do
    before do
      @hash       = Hammer::Weak::WeakKeyHash.new
      key         = 'weak'
      @key        = 'strong'
      @hash[key]  = 1
      @hash[@key] = 2
    end

    it 'should drop a and have b' do
      gc
      @hash[@key].must_equal 2
      @hash.to_a.size.must_equal 1
    end

    describe 'key conversion' do
      ['a', Object.new].each do |key|
        it "should keep object_id of #{key.inspect}" do
          hash      = Hammer::Weak::WeakKeyHash.new
          hash[key] = 1
          hash.to_a[0][0].object_id.must_equal key.object_id
        end
      end
    end

    #describe 'garbage collection test' do
    #  6.times do |i|
    #    it "should gc" do
    #      isolate do
    #        keys           = [5.5, 1, :A, true, false, nil]
    #        @hash          = Hammer::Weak::WeakKeyHash.new
    #        @hash[keys[i]] = 'value'
    #        #p keys[i], i
    #        #p @hash[keys[i]]
    #      end
    #      gc
    #      p @hash.to_a
    #      #@hash.to_a.size.must_equal 0, "key #{@hash.to_a[0][0].inspect rescue nil} was not gc"
    #      @hash.to_a.size.must_equal 0, "key #{@hash.to_a[0][0].inspect rescue nil} was not gc"
    #    end
    #  end
    #end
  end

  describe Hammer::Weak::WeakHash do
    describe 'gc' do
      it 'should gc weak => weak' do
        isolate do
          @hash      = Hammer::Weak::WeakHash.new
          @hash['a'] = 'a'
        end
        gc
        @hash.to_a.size.must_equal 0
      end

      it 'should gc strong => weak' do
        isolate do
          @hash             = Hammer::Weak::WeakHash.new
          @hash[@key = 'a'] = 'a'
        end
        gc
        @hash.to_a.size.must_equal 0
      end

      it 'should gc weak => strong' do
        isolate do
          @hash      = Hammer::Weak::WeakHash.new
          @hash['a'] = (@value = 'a')
        end
        gc
        @hash.to_a.size.must_equal 0
      end

      it 'should not gc strong => strong' do
        isolate do
          @hash             = Hammer::Weak::WeakHash.new
          @hash[@key = 'a'] = (@value = 'a')
        end
        gc
        @hash.to_a.size.must_equal 1
      end

    end
    #before do
    #  @hash       = Hammer::Weak::WeakHash.new
    #  key         = 'weak'
    #  @key        = 'strong'
    #  value       = 'weak'
    #  @value      = 'strong'
    #  @hash[key]  = value
    #  @hash[@key] = value
    #  @hash[key]  = value
    #  @hash[@key] = value
    #end
  end
end