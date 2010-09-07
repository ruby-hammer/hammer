# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hammer::Finalizer do

  F = Hammer::Finalizer

  def trigger_gc
    ObjectSpace.define_finalizer(Object.new, proc {}) # hack for 1.9, i do not why
    ObjectSpace.garbage_collect
  end

  def self.finalizer(num)
    proc { $run << num }
  end

  def finalizer(num)
    self.class.finalizer(num)
  end

  before { $run = [] }
  after { trigger_gc }

  describe '.add' do
    before do 
      F.add obj = Object.new, nil, finalizer(1)
      F.add obj, :a, finalizer(2)
      F.add Object.new, :a, finalizer(3)
      @object_id = obj.object_id
    end

    def object
      ObjectSpace._id2ref @object_id
    end

    describe '.get(obj, nil)' do
      subject { F.get object, nil }
      it{ should be_kind_of(Proc) }
    end

    describe '.get(obj)' do
      subject { F.get object }
      it { should be_kind_of(Hash) }
      it { should have_key(:a) }
      it { should have_key(nil) }
      it { should have(2).items }
    end

    describe '.get' do
      subject { F.get }
      it { should be_kind_of(Hash) }
      it { should have(2).items }
    end

    describe 'after GC' do
      before { trigger_gc }
      
      describe '.get' do
        subject { F.get }
        it { should be_kind_of(Hash) }
        it { should have(0).items }
      end

      describe '$run' do
        subject { $run }
        it { should == [1,2,3] }
      end
    end

    describe 'when one is removed' do
      before do
        F.remove(object, nil)
        trigger_gc
      end

      describe '$run' do
        subject { $run }
        it { should == [2,3] }
      end
    end
  end

end
