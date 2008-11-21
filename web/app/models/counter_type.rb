class CounterType
  attr_reader :grapher

  def initialize(dod)
    @grapher = dod.grapher
    @title = dod.unique_name
    @uri = dod.uri
    @dod = dod
  end

  def default_graph
    Graph.new(@dod.name, @dod.unique_name, @dod.uri)
  end

  def to_json
    {
      :grapher => @grapher,
      :title => @title,
      :url => @uri,
      :timespans => Timespan.standard(@dod)
    }.to_json
  end
end
