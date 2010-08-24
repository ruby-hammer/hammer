# encoding: UTF-8 FIXME remove all

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hammer::Widget::Component do

  include HammerMocks

  let (:klass) do
    klass = Class.new(Hammer::Widget::Base)
    klass.wrap_in(:span)
    klass
  end

  describe '#a' do
    subject { klass.new(:component => component_mock) {|w| w.a 'test' }.to_html }
    it { should match(/href="#"/) }
  end

end
