#!/usr/bin/env/ruby

require 'logger'

class RrdWriter
	def initialize(cfg)
		@cfg = cfg
	end

	def get_rrd_file(type, key)
		file = @cfg.data.join(key.to_s.downcase + "-" + type + ".rrd")
		dir = file.parent
		if !dir.directory? then
			dir.mkpath
		end
		file
	end

	def rrd(command)
		Configuration.log.debug(command)
		system("/usr/bin/rrdtool #{command}")
	end
end
