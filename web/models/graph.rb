class Graph
  def initialize(title, image, uri)
    @title = title
    @image = image
    @uri = uri
  end

  def as_json(options={})
    {
      :title => @title,
      :image => @image,
      :uri => @uri
    }
  end
end
