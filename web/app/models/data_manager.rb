require 'pathname'

class DatabaseOnDisk
	attr_reader :path
	attr_reader :source
	attr_reader :grapher
	attr_reader :name

	def initialize(grapher, source, name, path)
		@grapher = grapher
		@source = source
		@name = name
		@path = path
    @display_name = name
	end

  def display_name=(value)
    @display_name = value
  end

  def display_name
    @display_name
  end

	def unique_name
		@path.basename('.rrd').to_s
	end

  def uri(starting='1days', ending='now', w=600, h=200)
    Merb::Router.url(:render, :source => @source, :name => @name, :grapher => @grapher, :starting => starting, :ending => ending, :w => w, :h => h)
  end
end

class Urls
  def self.item(name)
    Merb::Router.url(:item, :name => name)
  end

  def self.source(name)
  end

  def self.graph(name)
  end
end

class Finder
	def initialize(cfg)
		@cfg = cfg
	end

	def databases
    all = []
		Dir[@cfg.data.join("*.rrd")].each do |file|
			path = Pathname.new(file)
			if path.basename.to_s =~ /^([^-]+)-(.+)-([^-]+)\.rrd$/ then
				all << DatabaseOnDisk.new($3.to_sym, $1, $2, path)
			end
		end
    all
	end
end

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

class CategorizedItem
  attr_reader :name

  def initialize(name, title, sources)
    @name = name
    @title = title
    @description = ''
    @sources = sources
  end

  def default_graph
    all_source.default_graph
  end

  def all_source
    @sources.each do |source|
      return source if source.name =~ /all/i
    end
    raise "All source is missing?"
  end

  def to_json
    { 
      :name => @name,
      :description => @description,
      :graph => default_graph,
      :sources => [],
      :uri => Urls.item(@name)
    }.to_json
  end
end

class CategorizedSource
  attr_reader :name

  def initialize(name, types)
    @name = name
    @types = types
  end

  def default_graph
    @types[0].default_graph
  end

  def to_json
    { 
      :name => @name,
      :types => @types
    }.to_json
  end
end

class DatabaseType
  attr_reader :grapher

  def initialize(dod)
    @grapher = dod.grapher
    @title = dod.unique_name
    @uri = dod.uri
    @dod = dod
  end

  def default_graph
    Graph.new(@dod.name, @dod.unique_name, @dod.uri)
  end

  def to_json
    {
      :grapher => @grapher,
      :title => @title,
      :url => @uri,
      :timespans => Timespan.standard(@dod)
    }.to_json
  end
end

class Timespan
  attr_reader :name

  def initialize(name, uri)
    @name = name
    @uri = uri
  end

  def self.standard(dod)
    [
      Timespan.new('4weeks', dod.uri('4weeks', 'now')),
      Timespan.new('1weeks', dod.uri('1weeks', 'now')),
      Timespan.new('3days', dod.uri('3days', 'now')),
      Timespan.new('1day', dod.uri('1day', 'now')),
      Timespan.new('6hours', dod.uri('6hours', 'now'))
    ]
  end

  def to_json
    {
      :name => @name,
      :uri => @uri
    }.to_json
  end
end

class Graph
  def initialize(name, title, image_uri)
    @name = name
    @title = title
    @image_uri = image_uri
    @related_graphs_uri = ''
  end

  def to_json
    {
      :name => @name,
      :title => @title,
      :related_graphs_uri => @related_graphs_uri,
      :image_uri => @image_uri
    }.to_json
  end
end

class DataManager
	def self.cfg=(value)
		@@cfg = value
	end

	def self.cfg
		@@cfg
	end

  def self.find_source(name)
    []
  end

  def self.find_item(name)
    []
  end

  def self.find_database_by_name(name)
    foreach_dod do |dod|
      next if dod.name != name
      return dod
    end
  end

  def self.find_database(source_name, name, grapher)
    foreach_dod do |dod|
      next if dod.source != source_name
      next if dod.name != name
      next if dod.grapher != grapher
      return dod
    end
    raise "Database Not Found: #{source_name} #{name} #{grapher}"
  end

  def self.find_categorized
    by_category = {}

    foreach_dod_by_category do |cname, dod|
      category = (by_category[cname] ||= {})
      sources = (category[dod.display_name] ||= {})
      dtypes = (sources[dod.source] ||= [])
      dtypes << DatabaseType.new(dod)
    end

    categories = by_category.map do |cname, v|
      evs = v.map do |ename, v|
        srcs = v.map do |sname, v|
          types = v.map do |dod|
            dod
          end
          types.sort! { |a, b| a.grapher.to_s <=> b.grapher.to_s }
          CategorizedSource.new(sname, types)
        end
        CategorizedItem.new(ename, ename, srcs)
      end
      evs.sort! { |a, b| a.name <=> b.name }
      Category.new(cname, evs)
    end
  end

  private
  def self.foreach_dod_by_category(&blk)
    foreach_dod do |dod|
      category = 'ALL'
      cfg.categories.each do |cdef|
        if new_name = cdef.transform(dod.name) then
          dod.display_name = new_name
          category = cdef.name
        end
      end
      yield category, dod
    end
  end

  def self.foreach_dod(&blk)
    databases.each do |dod|
      yield dod
    end
  end

  def self.databases
		@@databases ||= Finder.new(cfg).databases
  end
end
