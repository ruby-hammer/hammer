class Hammer::Core::IdGenerator

  def initialize
    @last_id = 0
  end

  def id
    (@last_id+=1).encode62
  end

  FROM = 62**5
  LIMIT = 62**6
  RANDOM = LIMIT - 1 - FROM

  def secure_id
    id + (FROM + SecureRandom.random_number(RANDOM)).encode62
  end

end
