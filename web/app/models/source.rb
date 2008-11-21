class Source
  attr_reader :name

  def initialize(name, types)
    @name = name
    @types = types
  end

  def default_graph
    @types[0].default_graph
  end

  def to_json
    { 
      :name => @name,
      :types => @types
    }.to_json
  end
end
