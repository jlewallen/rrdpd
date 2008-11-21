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
				all << DatabaseOnDisk.new($3.to_sym, $1, $2, path)
			end
		end
    all
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
      ctypes = (sources[dod.source] ||= [])
      ctypes << CounterType.new(dod)
    end

    categories = by_category.map do |cname, v|
      evs = v.map do |ename, v|
        srcs = v.map do |sname, v|
          types = v.map do |dod|
            dod
          end
          types.sort! { |a, b| a.grapher.to_s <=> b.grapher.to_s }
          Source.new(sname, types)
        end
        Item.new(ename, ename, srcs)
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
