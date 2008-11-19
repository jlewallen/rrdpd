require 'pathname'

class DatabaseOnDisk
	attr_reader :type
	attr_reader :source
	attr_reader :name
	attr_reader :path

	def initialize(type, source, name, path)
		@type = type
		@source = source
		@name = name
		@path = path
	end

	def unique_name
		@path.basename(".rrd").to_s
	end

	def output_name
		@path.parent.join(unique_name + ".png")
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

class Statistics
  def initialize
    @sources = {}
    @events = {}
  end

  def add(dod)
    if !@sources.has_key?(dod.source) then
      @sources[dod.source] = Source.new(dod.source)
    end
    if !@events.has_key?(dod.name) then
      @events[dod.name] = Event.new(dod.name)
    end
  end

  def events
    @events.values
  end

  def sources
    @sources.values
  end
end

class DataManager
	def DataManager.cfg=(value)
		@@cfg = value
	end

	def DataManager.find_all
		get_statistics.events
	end

  private
  def DataManager.get_statistics
    statistics = Statistics.new
		finder = Finder.new(@@cfg)
		finder.databases do |dod|
      statistics.add(dod)
		end
    statistics
  end
end