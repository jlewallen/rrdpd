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
			if path.basename.to_s =~ /^(.+)-(.+)-(.+)\.rrd$/ then
				yield DatabaseOnDisk.new($3.to_sym, $1, $2, path)
			end
		end
	end
end

class DatabaseDataManager
	def DatabaseDataManager.cfg=(value)
		@@cfg = value
	end

	def DatabaseDataManager.find_all
		databases = []
		finder = Finder.new(@@cfg)
		finder.databases do |dod|
			databases << dod
		end
		databases
	end
end
