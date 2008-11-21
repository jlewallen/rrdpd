class Graph
  def initialize(title, uri)
    @title = title
    @uri = uri
  end

  def to_json
    {
      :title => @title,
      :uri => @uri
    }.to_json
  end
end
