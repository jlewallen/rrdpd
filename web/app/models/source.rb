class Source
  attr_reader :name

  def id
    @name
  end

  def events
    @by_name.values
  end

  def display_name
    name.capitalize
  end

  def initialize(name)
    @name = name
    @by_name = {}
  end

  def add(event)
    return if @by_name.has_key?(event.name)
    @by_name[event.name] = event
  end
end
