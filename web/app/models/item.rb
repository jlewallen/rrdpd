class Item
  attr_reader :name

  def initialize(name, title, sources)
    @name = name
    @title = title
    @description = ''
    @sources = sources
  end

  def default_graph
    all_source.default_graph
  end

  def all_source
    @sources.each do |source|
      return source if source.name =~ /all/i
    end
    raise "All source is missing?"
  end

  def to_json
    { 
      :name => @name,
      :description => @description,
      :graph => default_graph,
      :sources => [],
      :uri => Urls.item(@name)
    }.to_json
  end
end
