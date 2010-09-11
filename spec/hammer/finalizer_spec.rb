# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hammer::Finalizer do
  include HammerMocks
  F = Hammer::Finalizer

  def self.finalizer(num)
    proc { $run << num }
  end

  def finalizer(num)
    self.class.finalizer(num)
  end

  before(:all) { GC.disable }
  before { trigger_gc }
  before { $run = [] }
  after { trigger_gc }

  describe '.add' do
    before do
      F.add obj = Object.new, nil, finalizer(1)
      F.add obj.object_id, :a, finalizer(2)
      F.add obj2 = Object.new, :a, finalizer(3)
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

    describe 'when one is removed' do
      before do
        F.remove(object, nil)
      end

      describe '.get(object)' do
        subject { F.get object }
        it { should be_kind_of(Hash) }
        it { should have(1).items }
        it { should have_key(:a) }
      end

      describe '.get' do
        subject { F.get}
        it { should be_kind_of(Hash) }
        it { should have(2).items }
        it { should have_key(@object_id) }
      end
    end

    describe 'when one is removed' do
      before do
        F.remove(@object_id, nil)
      end

      describe '.get(object)' do
        subject { F.get object }
        it { should be_kind_of(Hash) }
        it { should have(1).items }
        it { should have_key(:a) }
      end

      describe '.get' do
        subject { F.get }
        it { should be_kind_of(Hash) }
        it { should have(2).items }
        it { should have_key(@object_id) }
      end
    end

  end

  describe 'weakness' do
    it 'run after gc and hold objects weakly' do
      isolate do
        F.add Object.new, :a, finalizer(1)
        F.add Object.new, :a, finalizer(2)

        F.get.should have(2).items
      end

      trigger_gc

      $run.should include(1,2)

      F.get.should == {}
    end
  end
end
