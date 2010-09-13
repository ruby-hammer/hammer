# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hammer::Weak::Queue do
  include HammerMocks
  Q = Hammer::Weak::Queue

  before(:all) { GC.disable }

  describe '#push' do
    before do
      @queue1 = Q.new
      @queue2 = Q.new
      @queue1.push(@obj1 = Object.new, @obj2 = Object.new)
      @queue2.push(@obj2)
    end

    it 'should include added elements' do
      @queue1.should include @obj1, @obj2
      @queue1.should have(2).items
      @queue2.should include @obj2
      @queue2.should have(1).items
    end

    describe "after delete" do
      before do
        @queue1.delete(@obj2)
        @queue2.delete(@obj2)
      end
      it 'should include added elements without deleted' do
        @queue1.should include @obj1
        @queue1.should have(1).items
        @queue2.should have(0).items
      end
    end
  end

  it 'should have weak properties' do
    isolate do
      o1 = Object.new
      o2 = Object.new
      @id1 = o1.object_id
      @id2 = o2.object_id
      @queue = Q.new.push(o1, o2)
    end

    trigger_gc

    @queue.should be_empty
    Hammer::Finalizer.get.should_not have_key(@id1)
    Hammer::Finalizer.get.should_not have_key(@id2)

    isolate do
      o1 = Object.new
      @id1 = o1.object_id
      queue = Q.new.push(o1)
      @queue_id = queue.object_id
    end

    trigger_gc

    Hammer::Finalizer.get.should_not have_key(@id1)
    Hammer::Finalizer.get.should_not have_key(@queue_id)
  end
end

describe Hammer::Weak::Hash[:value] do
  include HammerMocks
  HV = Hammer::Weak::Hash[:value]
  before(:all) { GC.disable }

  describe 'hash behaveior' do
    before do
      @hash = HV.new
      @hash[:a] = @str = 'a'
      @hash['b'] = 'b'
      @hash[:c] = @str
      @hash2 = HV.new
      @hash2[:a] = @str
    end
    it 'should containt added elements' do
      @hash.should have_key(:a)
      @hash.should have_key('b')
      @hash.should have_key(:c)
      @hash2.should have_key(:a)
      @hash['b'].should == 'b'
      @hash[:a].object_id.should == @hash[:c].object_id
      @hash2[:a].object_id.should == @hash[:c].object_id
      @hash.size.should == 3
      @hash2.size.should == 1
    end

    describe "after owerwriting and deleting" do
      before do
        @hash[:a] = 'c'
        @hash['b'] = 12.3
        @hash.delete :c
      end
      it 'should have changed elements' do
        @hash.should have_key(:a)
        @hash.should have_key('b')
        @hash.should_not have_key(:c)
        @hash[:a].should == 'c'
        @hash['b'].should == 12.3
        @hash.size.should == 2
      end
    end
  end

  it 'elements should have weak properties' do
    isolate do
      @h = HV.new
      @deleted_id = (@h['key'] = Object.new).object_id
      @h[:a] = @o = Object.new
      @h['key'].nil?.should == false
    end

    trigger_gc

    @h['key'].should be_nil
    @h[:a].should_not be_nil
    Hammer::Finalizer.get(@deleted_id).should be_blank
  end

  it 'hash should have weak properties' do
    isolate do
      h = HV.new
      @hash_id = h.object_id
      h[:a] = @o = Object.new
      h[:b] = o = Object.new
      @obj1_id = @o.object_id
      @obj2_id = o.object_id
    end

    trigger_gc

    Hammer::Finalizer.get(@hash_id).should be_blank
    Hammer::Finalizer.get(@obj1_id, @hash_id).should be_blank
    Hammer::Finalizer.get(@obj2_id, @hash_id).should be_blank
  end
end

describe Hammer::Weak::Hash[:key] do
  include HammerMocks
  HK = Hammer::Weak::Hash[:key]
  before(:all) { GC.disable }

  describe 'hash behaveior' do
    before do
      @hash = HK.new
      @hash[@obj = Object.new] = 'a'
      @hash[@obj1 = Object.new] = 'd'
      @hash['b'] = 'b'
      @hash['c'] = @obj
      @hash2 = HK.new
      @hash2['d'] = @obj
    end
    it 'should containt added elements' do
      @hash.should have_key(@obj)
      @hash.should have_key('b')
      @hash.should have_key('c')
      @hash2.should have_key('d')
      @hash[@obj].should == 'a'
      @hash['b'].should == 'b'
      @hash['c'].should == @obj
      @hash['c'].object_id.should == @hash2['d'].object_id
      @hash.size.should == 4
      @hash2.size.should == 1
    end

    describe "after owerwriting and deleting" do
      before do
        @hash[@obj] = 'c'
        @hash['b'] = 12.3
        @hash.delete 'c'
        @hash.delete @obj1
      end
      it 'should have changed elements' do
        @hash.should have_key(@obj)
        @hash.should have_key('b')
        @hash.should_not have_key('c')
        @hash.should_not have_key(@obj1)
        @hash[@obj].should == 'c'
        @hash[@obj1].should == nil
        @hash['b'].should == 12.3
        @hash['c'].should == nil
        @hash.size.should == 2
      end
    end
  end

  it 'elements should have weak properties' do
    isolate do
      @h = HK.new
      @h[k = Object.new] = 'value'
      @h[@key = Object.new] = 'value2'
      @k_id = k.object_id
    end

    trigger_gc

    @h.should have(1).items
    @h[@key].should == 'value2'
    Hammer::Finalizer.get(@k_id).should be_blank
  end

  it 'hash should have weak properties' do
    isolate do
      h = HK.new
      @hash_id = h.object_id
      h[@k1 = 'a'] = Object.new
      h[k2 = 'b'] = Object.new
      @k1_id = @k1.object_id
      @k2_id = k2.object_id
    end

    trigger_gc

    Hammer::Finalizer.get(@hash_id).should be_blank
    Hammer::Finalizer.get(@k1_id, @hash_id).should be_blank
    Hammer::Finalizer.get(@k2_id, @hash_id).should be_blank
  end

  describe 'diffrent objects with same hash' do

    class O
      attr_reader :num
      def initialize(num)
        @num = num
      end

      def eql?(other)
        num == other.num
      end

      def hash
        num % 2
      end
    end

    it 'should behave correct for objects with same hash but unequql' do
      h = HK.new
      h[k1 = O.new(0)] = 'a'
      h[k2 = O.new(2)] = 'b'

      k1.hash.should == k2.hash
      k1.should_not be_eql(k2)

      h[k1].should == 'a'
      h[k2].should == 'b'
    end

  end

end

#describe Hammer::Weak::ReferenceFinder do
#  RF = Hammer::Weak::ReferenceFinder
#  it {
#    @id = Object.new
#    RF.find(self, @id.object_id)
#  }
#end

