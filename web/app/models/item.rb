require 'set'

class SourceSet < SortedSet
  def default
    self.each do |s|
      return s if s.is_default
    end
    nil
  end
end

class CounterSet < SortedSet
  def default
    self.each do |s|
      return s if s.is_default
    end
    nil
  end
end

class Item
  include Comparable

  attr_reader :name
  attr_reader :sources
  attr_reader :counters

  def initialize(name, category)
    @name = name
    @category = category
    @sources = SourceSet.new
    @counters = CounterSet.new
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

  def browser
    Browser.new(self)
  end

  def graphable(source, counter)
    Graphable.new(source.name, name, counter.name)
  end

  def <=>(anOther)
    name <=> anOther.name
  end
end

class Browser
  def initialize(item)
    @item = item
  end

  def graphs
    source = @item.sources.default
    counter = @item.counters.default
    graphable = @item.graphable(source, counter)
    [ graphable.to_graph ]
  end

  def to_json
    {
      :name => @item.name,
      :graphs => graphs
    }.to_json
  end
end

class Graphable
  def initialize(source, name, counter)
    @source = source
    @name = name
    @counter = counter
  end

  def title
    @source + " " + @name + " " + @counter.to_s
  end

  def parameters
    {
      :source => @source,
      :name => @name,
      :grapher => @counter,
      :starting => '1day',
      :ending => 'now',
      :w => 600,
      :h => 200
    }
  end

  def default_uri
    Merb::Router.url(:render, parameters)
  end

  def to_graph
    Graph.new(title, default_uri)
  end
end
