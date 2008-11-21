require 'pathname'

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
				all << create(path, $1, $2, $3.to_sym)
			end
		end
    all
	end

  private
  def create(path, source, name, grapher)
    category = Category::DEFAULT_NAME
    @cfg.categories.each do |cdef|
      if changed = cdef.transform(name) then
        name = changed
        category = cdef.name
      end
    end
    DatabaseOnDisk.new(path, category, source, name, grapher)
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
    databases.each do |dod|
      next if dod.name != name
      return dod
    end
  end

  def self.find_database(source_name, name, grapher)
    databases.each do |dod|
      next if dod.source != source_name
      next if dod.name != name
      next if dod.grapher != grapher
      return dod
    end
    raise "Database Not Found: #{source_name} #{name} #{grapher}"
  end

  def self.find_categorized
    by_category = {}
    categories = {}
    items = {}
    sources = {}
    counter_types = {}

    databases.each do |dod|
      category = (categories[dod.category] ||= Category.new(dod.category))
      source = (sources[dod.source] ||= Source.new(dod.source))
      item = (items[dod.name] ||= Item.new(dod.name))
      counter_type = (counter_types[dod.grapher] ||= CounterType.new(dod.grapher))
      item.add_source(source)
      item.add_counter_type(counter_type)
      category.add_item(item)
    end

    categories.values
  end

  private
  def self.databases
		@@databases ||= Finder.new(cfg).databases
  end
end
