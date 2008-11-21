require 'set'

class Item
  include Comparable

  attr_reader :name

  def initialize(name)
    @name = name
    @sources = SortedSet.new
    @counter_types = SortedSet.new
  end

  def add_counter_type(type)
    @counter_types << type
  end

  def add_source(source)
    @sources << source
  end

  def to_json
    { 
      :name => @name,
      :description => '',
      :sources => @sources.to_a,
      :counter_types => @counter_types.to_a,
      :uri => Urls.item(@name)
    }.to_json
  end

  def <=>(anOther)
    name <=> anOther.name
  end
end
