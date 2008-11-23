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
  attr_reader :category

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
      :uri => Urls.graph(@category.name, @name, @sources.default.name, @counters.default.name, '1day'),
      :preview => browser(nil, nil, { :w => 300, :h => 100 }).to_graphs[0]
    }.to_json
  end

  def browser(source=nil, counter=nil, parameters={})
    source = source ? @sources.named?(source) : @sources.default
    counter = counter ? @counters.named?(counter) : @counters.default
    Browser.new(self, source, counter, parameters)
  end

  def <=>(anOther)
    name <=> anOther.name
  end
end

class MenuEntry
  def initialize(title, children)
    @title = title
    @children = children
  end

  def to_json
    {
      :title => @title,
      :children => @children
    }.to_json
  end
end

class Browser
  def initialize(item, source, counter, parameters)
    @item = item
    @source = source
    @counter = counter
    @parameters = parameters
    @graphable = Graphable.new(@item.category.name, @source.name, @item.name, @counter.name, @parameters)
  end

  def to_graphs
    [ @graphable.to_graph ]
  end

  def to_json
    {
      :name => @item.name,
      :graphs => to_graphs,
      :menu => [
        {
          :title => 'counter',
          :submenu => [
            { :title => 'yesno', :graph => @graphable.to_graph({ :counter => :yesno }) },
            { :title => 'quartiles', :graph => @graphable.to_graph({ :counter => :quartiles }) }
          ]
        },
        {
          :title => 'timespan',
          :submenu => [
            { :title => '1hour',   :graph => @graphable.to_graph({ :starting => '1hour'   }) },
            { :title => '8hours',  :graph => @graphable.to_graph({ :starting => '8hours'  }) },
            { :title => '1day',    :graph => @graphable.to_graph({ :starting => '1day'    }) },
            { :title => '2days',   :graph => @graphable.to_graph({ :starting => '2days'   }) },
            { :title => '3days',   :graph => @graphable.to_graph({ :starting => '3days'   }) },
            { :title => '1week',   :graph => @graphable.to_graph({ :starting => '1week'   }) },
            { :title => '2week',   :graph => @graphable.to_graph({ :starting => '2week'   }) },
            { :title => '4week',   :graph => @graphable.to_graph({ :starting => '4week'   }) },
            { :title => '3months', :graph => @graphable.to_graph({ :starting => '3months' }) },
            { :title => '6months', :graph => @graphable.to_graph({ :starting => '6months' }) },
            { :title => '1year',   :graph => @graphable.to_graph({ :starting => '1year'   }) }
          ]
        }
      ]
    }.to_json
  end
end

class Graphable
  def initialize(category, source, name, counter, parameters)
    @category = category
    @source = source
    @name = name
    @counter = counter
    @parameters = {
      :source => @source,
      :name => @name,
      :counter => @counter,
      :starting => '1day',
      :ending => 'now',
      :w => 600,
      :h => 200
    }.merge(parameters)
  end

  def to_graph(extra={})
    p = @parameters.merge(extra)
    Graph.new(title, image_uri(p), uri(p))
  end

  private
  def uri(p)
    Urls.graph(@category, @name, @source, p[:counter], p[:starting])
  end

  def image_uri(p)
    Merb::Router.url(:render, p)
  end

  def title
    @category + " - " + @source + " - " + @name + " - " + @counter.to_s + " - " + @parameters[:starting]
  end
end
