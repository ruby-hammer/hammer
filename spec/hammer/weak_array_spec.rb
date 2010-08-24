# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hammer::WeakArray do

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
end

describe Hammer::WeakArray::ReferenceStore do
  let(:store) { Hammer::WeakArray::ReferenceStore.new }
  let(:reference_array_by_weakhash_id) do
    store.instance_variable_get :@reference_array_by_weakhash_id
  end
  let(:reference_arrays_by_obj_id) do
    store.instance_variable_get :@reference_arrays_by_obj_id
  end

  describe '#add(1,-1)' do
    before { store.add(1, -1) }

    it { reference_array_by_weakhash_id.to_s.should == { 1 => [-1] }.to_s }
    it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1]]}.to_s }
    it { store.reference_array(1).to_s.should == [-1].to_s }
    it { store.reference_arrays(-1).to_s.should == [[-1]].to_s }

    describe '#add(1,-2)' do
      before { store.add(1, -2) }

      it { reference_array_by_weakhash_id.to_s.should == {1 => [-1, -2]}.to_s }
      it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1, -2]], -2 => [[-1, -2]]}.to_s }
      it { store.reference_array(1).to_s.should == [-1, -2].to_s }
      it { store.reference_arrays(-1).to_s.should == [[-1, -2]].to_s }
      it { store.reference_arrays(-2).to_s.should == [[-1, -2]].to_s }

      describe '#remove(1, -1)' do
        before { store.remove(1, -1) }
        it { reference_array_by_weakhash_id.to_s.should == {1 => [-2]}.to_s }
        it { reference_arrays_by_obj_id.to_s.should == {-2 => [[-2]]}.to_s }
      end

      describe '#remove_weak_array(1)' do
        before { store.remove_weak_array(1) }
        it { reference_array_by_weakhash_id.to_s.should == {}.to_s }
        it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
      end

      describe '#remove_object_id(-2)' do
        before { store.remove_object_id(-2) }
        it { reference_array_by_weakhash_id.to_s.should == { 1 => [-1] }.to_s }
        it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1]]}.to_s }
      end
    end

    describe '#add(2,-1)' do
      before { store.add(2, -1) }
      it { reference_array_by_weakhash_id.to_s.should == {1 => [-1], 2 => [-1]}.to_s }
      it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1],[-1]]}.to_s }

      describe '#remove(2, -1)' do
        before { store.remove(2, -1) }
        it { reference_array_by_weakhash_id.to_s.should == {1 => [-1], 2 => []}.to_s }
        it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1]]}.to_s }
      end

      describe '#remove_weak_array(1)' do
        before { store.remove_weak_array(1) }
        it { reference_array_by_weakhash_id.to_s.should == {2 => [-1]}.to_s }
        it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1]]}.to_s }

        describe '#remove_object_id(-1)' do
          before { store.remove_object_id(-1) }
          it { reference_array_by_weakhash_id.to_s.should == {2 => []}.to_s }
          it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
        end

        describe '#remove_weak_array(2)' do
          before { store.remove_weak_array(2) }
          it { reference_array_by_weakhash_id.to_s.should == {}.to_s }
          it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
        end
      end

    end

    describe '#add(1,-1)' do
      before { store.add(1, -1) }
      it { reference_array_by_weakhash_id.to_s.should == {1 => [-1, -1]}.to_s }
      it { reference_arrays_by_obj_id.to_s.should == {-1 => [[-1,-1]]}.to_s }

      describe '#remove_object_id(-1)' do
        before { store.remove_object_id(-1) }
        it { reference_array_by_weakhash_id.to_s.should == {1 => []}.to_s }
        it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
      end

      describe '#remove_weak_array(1)' do
        before { store.remove_weak_array(1) }
        it { reference_array_by_weakhash_id.to_s.should == {}.to_s }
        it { reference_arrays_by_obj_id.to_s.should == {}.to_s }
      end

    end
  end

end
