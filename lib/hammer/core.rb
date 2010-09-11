module Hammer::Core

  @last_id = 0
  def self.generate_id
    #      UUID.generate(:compact).to_i(16).to_s(36)
    (@last_id+=1).to_s(36)
  end

  # FIXME dangerous, add own ids to components an store hash on context
  def self.component_by_id(id)
    begin ObjectSpace._id2ref(id.to_i) rescue RangeError end
  end

end