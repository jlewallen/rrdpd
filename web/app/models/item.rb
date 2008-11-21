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
  def initialize(item, source=nil, counter=nil)
    @item = item
    @source = source || item.sources.default
    @counter = counter || item.counters.default
    @graphable = Graphable.new(@source.name, @item.name, @counter.name)
  end

  def graphs
    [
    @graphable.to_graph
    ]
  end

  def to_json
    {
      :name => @item.name,
      :graphs => graphs,
      :menu => {
        :timespan => {
          '1day'  => @graphable.to_graph({ :starting => '1day'  }),
          '3days' => @graphable.to_graph({ :starting => '3days' }),
          '1week' => @graphable.to_graph({ :starting => '1week' }),
          '2week' => @graphable.to_graph({ :starting => '2week' }),
          '4week' => @graphable.to_graph({ :starting => '4week' })
        }
      }
    }.to_json
  end
end

class Graphable
  def initialize(source, name, counter)
    @source = source
    @name = name
    @counter = counter
  end

  def to_graph(extra={})
    Graph.new(title, uri(extra))
  end

  private
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

  def uri(extra={})
    Merb::Router.url(:render, parameters.merge(extra))
  end

  def title
    @source + " " + @name + " " + @counter.to_s
  end
end
