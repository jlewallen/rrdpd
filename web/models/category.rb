require 'set'

class Category
  DEFAULT_NAME = 'Default'

  attr_reader :name
  attr_reader :items

  def initialize(name)
    @name = name
    @items = SortedSet.new
  end

  def add_item(item)
    @items << item
  end

  def item?(name)
    @items.select { |item| item.name == name }.first
  end

  def to_json
    { 
      :name => @name,
      :items => @items.to_a
    }.to_json
  end
end
