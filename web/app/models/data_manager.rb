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

  def uri
    Merb::Router.url(:render, :source => @source, :event => @name, :grapher => @grapher, :start_at => '1days', :end_at => 'now')
  end
end

class Finder
	def initialize(cfg)
		@cfg = cfg
	end

	def databases(&blk)
		Dir[@cfg.data.join("*.rrd")].each do |file|
			path = Pathname.new(file)
			if path.basename.to_s =~ /^([^-]+)-(.+)-([^-]+)\.rrd$/ then
				yield DatabaseOnDisk.new($3.to_sym, $1, $2, path)
			end
		end
	end
end

class Category
  attr_reader :name
  attr_reader :events

  def initialize(name, events)
    @name = name
    @events = events
  end

  def to_json
    { 
      :name => @name,
      :events => @events
    }.to_json
  end
end

class CategorizedSource
  attr_reader :name
  attr_reader :types

  def initialize(name, types)
    @name = name
    @types = types
  end

  def to_json
    { 
      :name => @name,
      :types => @types
    }.to_json
  end
end

class CategorizedEvent
  attr_reader :name
  attr_reader :title
  attr_reader :sources

  def initialize(name, title, sources)
    @name = name
    @title = title
    @sources = sources
  end

  def to_json
    { 
      :name => @name,
      :sources => @sources
    }.to_json
  end
end

class DatabaseType
  attr_reader :grapher
  attr_reader :title
  attr_reader :uri

  def initialize(dod)
    @grapher = dod.grapher
    @title = dod.unique_name
    @uri = dod.uri
  end

  def to_json
    {
      :grapher => @grapher,
      :title => @title,
      :url => @uri
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

  def self.find(source_name, name, grapher)
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

    by_category.map do |cname, v|
      evs = v.map do |ename, v|
        srcs = v.map do |sname, v|
          types = v.map do |dod|
            dod
          end
          CategorizedSource.new(sname, types)
        end
        CategorizedEvent.new(ename, ename, srcs)
      end
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
		finder = Finder.new(cfg)
		finder.databases do |dod|
      yield dod
    end
  end
end
