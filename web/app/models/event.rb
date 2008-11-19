class Event
  attr_reader :name

  def id
    @name
  end

  def display_name
    name
  end

  def initialize(name)
    @name = name
  end
end
