# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'rack/test'


describe Hammer::Core::Application do
  include Rack::Test::Methods

  def app
    Hammer::Core::Application
  end

  before { get '/' }

  it { last_response.should be_ok }
  it { last_response.body.should match(/js\/swfobject\.js/) }
  it { last_response.body.should match(/js\/FABridge\.js/) }
  it { last_response.body.should match(/js\/web_socket\.js/) }
  it { last_response.body.should match(/js\/jquery-/) }
  it { last_response.body.should match(/js\/jquery\.ba-hashchange\.js/) }
  it { last_response.body.should match(/js\/hammer\.js/) }
end
