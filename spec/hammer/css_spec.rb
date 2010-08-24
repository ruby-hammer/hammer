# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hammer::CSS do

  describe Hammer::CSS::Selector do
    let(:builder) { mock(:builder, :selectors => []) }
    Selector = Hammer::CSS::Selector
    it { Selector.new(builder, "div").to_s.should == "* div {}\n\n" }
    it { Selector.new(builder, "a", :href).to_s.should == "* a:href {}\n\n" }
    it { Selector.new(builder, "a", '[href]').to_s.should == "* a[href] {}\n\n" }
    it { Selector.new(builder, "div", :id => "aId").to_s.should == "* div#aId {}\n\n" }
    it { Selector.new(builder, "div", :class => "aClass").to_s.should == "* div.aClass {}\n\n" }
    it { (Selector.new(builder, "div", :class => "aClass") + Selector.new(builder, "h1")).to_s.
          should == "* div.aClass+h1 {}\n\n" }
    it { (Selector.new(builder, "div") | Selector.new(builder, "h1")).to_s.should == "* div, * h1 {}\n\n" }
    it { (Selector.new(builder, :div) >> Selector.new(builder, "h1")).to_s.should == "* div h1 {}\n\n" }
    it { (Selector.new(builder, :div) >> Selector.new(builder, "h1") | Selector.new(builder, :a)).to_s.
          should == "* div h1, * a {}\n\n" }
  end

  describe Hammer::CSS::Properties do
    Properties = Hammer::CSS::Properties
    it { Properties.new { width('100px'); float(:left) }.to_s.should == "  width: 100px;\n  float: left;\n" }
    it { Properties.new { list_style('square') }.to_s.should == "  list-style: square;\n" }
  end

  describe Hammer::CSS::Builder do
    Builder = Hammer::CSS::Builder
    it { Builder.new { div { width '100px' }; ul | li {margin 0}; a :href }.to_s.should == <<-CSS }
* div {
  width: 100px;
}

* ul, * li {
  margin: 0;
}

* a:href {}

    CSS
  end

  describe Hammer::CSS::Builder do
    Builder = Hammer::CSS::Builder
    it { Builder.new { div { width '100px' }; ul | li {margin 0}; a :href }.to_s('space').should == <<-CSS }
.space div {
  width: 100px;
}

.space ul, .space li {
  margin: 0;
}

.space a:href {}

    CSS
  end

  describe Hammer::CSS::Builder do
    Builder = Hammer::CSS::Builder
    it { Builder.new { ul | li {margin 0} }.to_s(%w{space1 space2}).should == <<-CSS }
.space1 ul, .space1 li, .space2 ul, .space2 li {
  margin: 0;
}

    CSS
  end

  describe Hammer::CSS::Builder do
    Builder = Hammer::CSS::Builder
    it { Builder.new { this! {margin 0}; this!(:hover) {color 'blue'} }.to_s(%w{space1 space2}).should == <<-CSS }
.space1, .space2 {
  margin: 0;
}

.space1:hover, .space2:hover {
  color: blue;
}

CSS
  end

end
