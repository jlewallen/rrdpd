require 'set'

class Item
  include Comparable

  attr_reader :name

  def initialize(name, category)
    @name = name
    @category = category
    @sources = SortedSet.new
    @counters = SortedSet.new
  end

  def add_counter(type)
    @counters << type
  end

  def add_source(source)
    @sources << source
  end

  def to_json
    { 
      :name => @name,
      :description => '',
      :sources => @sources.to_a,
      :counters => @counters.to_a,
      :uri => Urls.item(@category.name, @name)
    }.to_json
  end

  def <=>(anOther)
    name <=> anOther.name
  end
end
