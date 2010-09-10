# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#describe Hammer::WeakArray do

# TODO rewrite weakarray test to rspec

#  def gc
#    GC.start
#    GC.start
#    sleep 0.2
#  end
#
#  def isolate
#    yield
#    nil
#  end

#  before { isolate { @array = Hammer::WeakArray.new }}
#
#  def add
#    isolate { @array.push Object.new }
#  end


#  describe 'with a obj' do
#    before { add }
#    it { should have(1).items }
#
#    describe 'after GC' do
#      before { gc }
#      it { isolate { should have(0).items } }
#    end
#  end

#  it do
#    isolate do
#      @weak_array = Hammer::WeakArray.new
#      @weak_array.push Object.new
#    end
#
#    isolate { @weak_array.to_a.should have(1).items }
#    gc
#    isolate { @weak_array.to_a.should have(0).items }
#  end
#
#  it do
#    lambda do
#      weak_id = lambda do
#        weak_array = Hammer::WeakArray.new
#        weak_array.object_id
#      end.call
#
#      lambda { ObjectSpace._id2ref(weak_id).should_not be_nil }.call
#      lambda { p Hammer::WeakArray::STORE }.call
#      GC.start
#      lambda { ObjectSpace._id2ref(weak_id) }.should raise_error
#      lambda { p Hammer::WeakArray::STORE }.call
#    end.call
#  end
#
#  it do
#    lambda do
#      elem, weak_id = lambda do
#        elem = Object.new
#        weak_array = Hammer::WeakArray.new
#        weak_array.push elem
#        weak_array.to_a.should have(1).items
#        [elem, weak_array.object_id]
#      end.call
#
#      lambda { ObjectSpace._id2ref(weak_id).should_not be_nil }.call
#      lambda { p Hammer::WeakArray::STORE }.call
#      GC.start
#      lambda { ObjectSpace._id2ref(weak_id) }.should raise_error
#      lambda { p Hammer::WeakArray::STORE }.call
#    end.call
#  end
#end

#describe Hammer::WeakArray::ReferenceStore do
#  let(:store) { Hammer::WeakArray::ReferenceStore.new }
#  let(:reference_array_by_weakhash_id) do
#    store.instance_variable_get :@reference_array_by_weakhash_id
#  end
#  let(:reference_arrays_by_obj_id) do
#    store.instance_variable_get :@reference_arrays_by_obj_id
#  end
#
#  describe '#add(1,-1)' do
#    before { store.add(1, -1) }
#
#    it { reference_array_by_weakhash_id.to_s.should == { 1 => [-1] }.to_s }
#    it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1]]}.to_s }
#    it { store.reference_array(1).to_s.should == [-1].to_s }
#    it { store.reference_arrays(-1).to_s.should == [[-1]].to_s }
#
#    describe '#add(1,-2)' do
#      before { store.add(1, -2) }
#
#      it { reference_array_by_weakhash_id.to_s.should == {1 => [-1, -2]}.to_s }
#      it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1, -2]], -2 => [[-1, -2]]}.to_s }
#      it { store.reference_array(1).to_s.should == [-1, -2].to_s }
#      it { store.reference_arrays(-1).to_s.should == [[-1, -2]].to_s }
#      it { store.reference_arrays(-2).to_s.should == [[-1, -2]].to_s }
#
#      describe '#remove(1, -1)' do
#        before { store.remove(1, -1) }
#        it { reference_array_by_weakhash_id.to_s.should == {1 => [-2]}.to_s }
#        it { reference_arrays_by_obj_id.to_s.should == {-2 => [[-2]]}.to_s }
#      end
#
#      describe '#remove_weak_array(1)' do
#        before { store.remove_weak_array(1) }
#        it { reference_array_by_weakhash_id.to_s.should == {}.to_s }
#        it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
#      end
#
#      describe '#remove_object_id(-2)' do
#        before { store.remove_object_id(-2) }
#        it { reference_array_by_weakhash_id.to_s.should == { 1 => [-1] }.to_s }
#        it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1]]}.to_s }
#      end
#    end
#
#    describe '#add(2,-1)' do
#      before { store.add(2, -1) }
#      it { reference_array_by_weakhash_id.to_s.should == {1 => [-1], 2 => [-1]}.to_s }
#      it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1],[-1]]}.to_s }
#
#      describe '#remove(2, -1)' do
#        before { store.remove(2, -1) }
#        it { reference_array_by_weakhash_id.to_s.should == {1 => [-1], 2 => []}.to_s }
#        it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1]]}.to_s }
#      end
#
#      describe '#remove_weak_array(1)' do
#        before { store.remove_weak_array(1) }
#        it { reference_array_by_weakhash_id.to_s.should == {2 => [-1]}.to_s }
#        it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1]]}.to_s }
#
#        describe '#remove_object_id(-1)' do
#          before { store.remove_object_id(-1) }
#          it { reference_array_by_weakhash_id.to_s.should == {2 => []}.to_s }
#          it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
#        end
#
#        describe '#remove_weak_array(2)' do
#          before { store.remove_weak_array(2) }
#          it { reference_array_by_weakhash_id.to_s.should == {}.to_s }
#          it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
#        end
#      end
#
#    end
#
#    describe '#add(1,-1)' do
#      before { store.add(1, -1) }
#      it { reference_array_by_weakhash_id.to_s.should == {1 => [-1, -1]}.to_s }
#      it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1,-1]]}.to_s }
#
#      describe '#remove_object_id(-1)' do
#        before { store.remove_object_id(-1) }
#        it { reference_array_by_weakhash_id.to_s.should == {1 => []}.to_s }
#        it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
#      end
#
#      describe '#remove_weak_array(1)' do
#        before { store.remove_weak_array(1) }
#        it { reference_array_by_weakhash_id.to_s.should == {}.to_s }
#        it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
#      end
#
#    end
#  end
#
#end

require 'pp'

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
      @hash.size.should == 3
      @hash2.size.should == 1
    end

    describe "after owerwriting and deleting" do
      before do
        @hash[@obj] = 'c'
        @hash['b'] = 12.3
        @hash.delete 'c'
      end
      it 'should have changed elements' do
        @hash.should have_key(@obj)
        @hash.should have_key('b')
        @hash.should_not have_key('c')
        @hash[@obj].should == 'c'
        @hash['b'].should == 12.3
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

