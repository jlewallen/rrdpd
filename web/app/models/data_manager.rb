require 'pathname'

class Urls
  def self.item(category, name, source, counter)
    Merb::Router.url(:item, :category => category, :name => name, :source => source, :counter => counter)
  end

  def self.graph(category, name, source, counter, starting)
    url(:graph, :category => category, :name => name, :source => source, :counter => counter, :starting => starting)
  end
  #match('/:source/:name/:counter/:starting/:ending/:w/:h', :source => /[^\/,;?]+/).to(:controller => 'render', :action => 'graph').name(:render)
  #match('/:category/:name/:source/:counter/:starting', :name => /[^\/,;?]+/).to(:controller => 'query', :action => 'graph').name(:graph)

  def self.url(name, p)
    if defined?(Merb)
      Merb::Router.url(name, p)
    else
      case name
      when :render
        "/#{p[:source]}/#{p[:name]}/#{p[:counter]}/#{p[:starting]}/#{p[:ending]}/#{p[:w]}/#{p[:h]}"
      when :item
        "/#{p[:category]}/#{p[:name]}/#{p[:source]}/#{p[:counter]}"
      when :graph
        "/#{p[:category]}/#{p[:name]}/#{p[:source]}/#{p[:counter]}/#{p[:starting]}"
      else
        raise "Unexpected #{name}"
      end
    end
  end
end

class DataManager
  def self.find_item(category, name)
    categories = find_categories
    category = categories[category]
    category.item?(name)
  end

  def self.find_database_by_name(name)
    find_databases.each do |dod|
      next if dod.name != name
      return dod
    end
  end

  def self.find_database(source_name, name, counter)
    find_databases.each do |dod|
      next if dod.source != source_name
      next if dod.name != name
      next if dod.counter != counter
      return dod
    end
    raise "Database Not Found: #{source_name} #{name} #{counter}"
  end

  def self.find_categorized
    find_categories.values
  end

  private
  def self.find_databases
		@@databases ||= Finder.new(Configuration.global).databases
  end

  def self.find_categories
    @@categories ||= ModelBuilder.new(Configuration.global).categories
  end
end

class ModelBuilder
  def initialize(cfg)
    @finder = Finder.new(cfg)
  end

  def categories
    categories = {}
    items = {}
    sources = {}
    counters = {}

    @finder.databases.each do |dod|
      category = (categories[dod.category] ||= Category.new(dod.category))
      source = (sources[dod.source] ||= Source.new(dod.source))
      item = (items[dod.name] ||= Item.new(dod.name, category))
      counter = (counters[dod.counter] ||= CounterType.new(dod.counter))
      item.add_source(source)
      item.add_counter(counter)
      category.add_item(item)
    end

    categories
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
				all << create(path, $1, $2, $3.to_sym)
			end
		end
    all
	end

  private
  def create(path, source, name, counter)
    category = Category::DEFAULT_NAME
    @cfg.categories.each do |cdef|
      if changed = cdef.transform(name) then
        name = changed
        category = cdef.name
      end
    end
    DatabaseOnDisk.new(path, category, source, name, counter)
  end
end
