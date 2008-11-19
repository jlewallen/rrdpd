class Source
  attr_reader :name

  def id
    @name
  end

  def initialize(name)
    @name = name
  end
end
