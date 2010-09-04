# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Component::Form do
  include HammerMocks
  setup_context

  class TestForm < Hammer::Component::Base
    include Hammer::Component::Form
    class Widget < superclass::Widget
      wrap_in :div
    end
  end

  let(:test_form) do
    TestForm.new :record => @struct = Struct.new(:record, :value, :name).new
  end

  describe '@record' do
    it { test_form.record.should be_present }
    it { test_form.record.should be_kind_of(Struct) }
    it { test_form.record.should == @struct }
  end

  describe '#set_value and #value' do
    describe "('value')" do
      before { test_form.set_value 'value' }
      subject { test_form.value }
      it { should == 'value' }
    end

    describe "(:name, 'name')" do
      before { test_form.set_value :name, 'name' }
      subject { test_form.value :name }
      it { should == 'name' }
    end
  end

  describe '#to_html' do
    subject { update test_form }
    it { should match(/id="#{test_form.object_id}"/) }
  end

end