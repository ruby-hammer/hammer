# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hammer::JQuery do

  describe Hammer::JQuery::MethodStack do
    tests = {
      'jquery.jq!' => "jQuery.jQuery()",
      'a.a!' => "a.a()",
      "a('a')" => "a(\"a\")",
      'a(1, nil)' => "a(1,null)",
      'a(1 => "a", :b => [1,2])' => "a({\"1\":\"a\",\"b\":[1,2]})",
    }

    tests.each do |ruby, jquery|
      describe ruby do
        it { Hammer::JQuery::MethodStack.new.instance_eval("self.#{ruby}").to_js.should == jquery }
      end
    end
  end

  tests = {
    'a.c!; b!;' => "a.c();b();",
    'a.c(b!);' => "a.c(b());",
    'a.c(b(c));' => "a.c(b(c));",
    'b(a!, a); a.c(b(c));' => "b(a(),a);a.c(b(c));",
    'b(a!, 1, "ab"); a.c(b(c));' => "b(a(),1,\"ab\");a.c(b(c));",
    'a.c!; b(function {b!.c!})' => 'a.c();b(function() {b().c();});',
    'b(function(a, 1.2) {b!.c!})' => 'b(function(a,1.2) {b().c();});',
    'function(a, 1.2) {b!.c!}' => 'function(a,1.2) {b().c();};',
    'function {b!}.a.b!' => 'function() {b();}.a.b();',
    'a :a => function(a) {b.c!}' => 'a({"a":function(a) {b.c();}});',
    'call(:Hammer).setOptions :a => 1' => 'Hammer.setOptions({"a":1});'
  }

  tests.each do |ruby, jquery|
    describe ruby do
      it { Hammer::JQuery.generate { eval ruby }.to_js.should == jquery }
    end
  end
end
