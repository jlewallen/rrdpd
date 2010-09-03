class Graph
  def initialize(title, image, uri)
    @title = title
    @image = image
    @uri = uri
  end

  def to_json
    {
      :title => @title,
      :image => @image,
      :uri => @uri
    }.to_json
  end
end
