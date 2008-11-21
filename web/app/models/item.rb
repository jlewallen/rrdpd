require 'set'

class SetWithefault < SortedSet
  def default
    self.each do |v|
      return v if v.is_default
    end
    nil
  end

  def named?(name)
    self.each do |v|
      return v if v.name == name
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
    @sources = SetWithefault.new
    @counters = SetWithefault.new
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

  def browser(source, counter)
    source = source ? @sources.named?(source) : @sources.default
    counter = counter ? @counters.named?(counter) : @counters.default
    Browser.new(self, source, counter)
  end

  def <=>(anOther)
    name <=> anOther.name
  end
end

class Browser
  def initialize(item, source, counter)
    @item = item
    @source = source
    @counter = counter
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
