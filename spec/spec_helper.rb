# encoding: UTF-8

require "#{File.dirname(__FILE__)}/../lib/hammer"

module HammerMocks
  def self.included(base)
    base.let(:container_mock) { mock(:container, :drop_context => true) }
    base.let(:context_mock) { mock(:context, :conteiner => container_mock, :root_component => false, :actions => []) }
    base.let(:component_mock) { mock(:component, :context => context_mock, :changed? => false, :root? => false,
        :passed? => false, :_children => []) }
    base.let(:widget_mock) { mock(:widget, :component => component_mock) }

    base.extend ClassMethods
  end

  module ClassMethods
    def setup_context
      let :context do
        Hammer::Core::Context.new('id', container_mock)
      end

      before { Hammer.stub(:get_context) { context } }

      define_method :update do |root_component|
        context.instance_eval { @root_component = root_component }
        context.unsended_components.map(&:to_html).join
      end
    end
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
end