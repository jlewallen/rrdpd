class Event
  attr_reader :name
  attr_reader :sources
  attr_reader :databases

  def id
    @name
  end

  def display_name
    name
  end

  def initialize(name)
    @name = name
    @databases = []
    @sources = []
  end

  def database(source, grapher)
    @databases.each do |dod|
      if dod.type == grapher and dod.source == source then
        return dod
      end
    end
  end

  def add_source(source)
    @sources << source
  end

  def add(dod)
    @databases << dod
  end
end
