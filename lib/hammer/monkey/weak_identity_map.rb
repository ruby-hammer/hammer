module DataMapper

  remove_const(:IdentityMap)

  # Tracks objects to help ensure that each object gets loaded only once.
  # See: http://www.martinfowler.com/eaaCatalog/identityMap.html
  class IdentityMap < Hammer::Weak::Hash[:value]
    extend Deprecate

    deprecate :get, :[]
    deprecate :set, :[]=

  end # class IdentityMap
end # module DataMapper