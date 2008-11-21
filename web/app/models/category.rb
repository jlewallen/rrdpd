class Category
  attr_reader :name

  def initialize(name, items)
    @name = name
    @items = items
  end

  def graphs
    @items.map do |ev|
      ev.default_graph
    end
  end

  def to_json
    { 
      :name => @name,
      :items => @items
    }.to_json
  end
end
