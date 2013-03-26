module Hammer::Components::Inspections
  class Example < Hammer::Component
    def to_url
      "inspection"
    end

    def from_url(url)
      @root = new Hash, :a => [1.0, 1, "asd", :asd], ['asd', 1] => 25
    end

    def content(b)
      b.c @root
    end
  end

  class Abstract < Hammer::Component
    def self.accept?(object)
      false
    end

    def self.inherited(subclass)
      subclasses << subclass
    end

    def self.subclasses
      self == Abstract ? @subclasses ||= [] : superclass.subclasses
    end

    def self.find_inspection_class(object)
      if self == Abstract
        subclasses.find { |klass| klass.accept? object } || raise("no inspection for #{object.inspect}")
      else
        superclass.find_inspection_class object
      end
    end

    def find_inspection_class(object)
      self.class.find_inspection_class object
    end

    attr_reader :object

    def initialize(app, object, options = { })
      super app, options
      @object = object
    end
  end

  class Packable < Abstract
    def initialize(app, object, options = { })
      super
      @packed = true
    end

    changing do
      def toggle
        packed? ? unpack : pack
      end

      def pack
        raise NotImplementedError
      end

      def unpack
        raise NotImplementedError
      end
    end

    def packed?
      @packed
    end
  end

  #class List < Hammer::Component
  #
  #end
  #
  #class Map < Hammer::Component
  #
  #end

  class Array < Packable
    def self.accept?(object)
      object.kind_of? ::Array
    end

    def unpack
      @packed      = false
      @inspections = object.map { |o| new find_inspection_class(o), o }
    end

    def pack
      @packed      = true
      @inspections = nil
    end

    def content(b)
      b.a("Array(#{object.size})").action { toggle }
      unless packed?
        b.ul { @inspections.each { |inspection| b.li { b.component inspection } } }
      end
    end
  end

  class Hash < Packable
    def self.accept?(object)
      object.kind_of? ::Hash
    end

    def unpack
      @packed      = false
      @inspections = object.map { |pair| new find_inspection_class(pair), pair }
    end

    def pack
      @packed      = true
      @inspections = nil
    end

    def content(b)
      b.a("Hash(#{object.size})").action { toggle }
      unless packed?
        b.ul { @inspections.each { |inspection| b.li { b.component inspection } } }
      end
    end
  end

  class Simple < Abstract
    def self.accept?(object)
      [::String, ::Numeric, ::Symbol].any? { |klass| object.kind_of? klass }
    end

    def content(b)
      b.text object.inspect
    end
  end
end