class Source
  attr_reader :name
  attr_reader :events

  def id
    @name
  end

  def display_name
    name.capitalize
  end

  def initialize(name)
    @name = name
    @events = []
  end

  def has_event(event)
    @events.each do |iter|
      if iter.name == event.name then
        return true
      end
    end
    false
  end

  def add_event(event)
    @events << event
  end
end
