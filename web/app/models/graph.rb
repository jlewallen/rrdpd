class Graph
  def initialize(title, uri)
    @title = title
    @uri = uri
    @related_graphs_uri = ''
  end

  def to_json
    {
      :title => @title,
      :related_graphs_uri => @related_graphs_uri,
      :uri => @uri
    }.to_json
  end
end
