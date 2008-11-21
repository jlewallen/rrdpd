class Graph
  def initialize(name, title, image_uri)
    @name = name
    @title = title
    @image_uri = image_uri
    @related_graphs_uri = ''
  end

  def to_json
    {
      :name => @name,
      :title => @title,
      :related_graphs_uri => @related_graphs_uri,
      :image_uri => @image_uri
    }.to_json
  end
end
