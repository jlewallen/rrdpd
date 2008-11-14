#!/usr/bin/env/ruby

require 'logger'

class RrdWriter
	def initialize(cfg)
		@cfg = cfg
	end

	def get_rrd_file(name)
		file = @cfg.data.join(name.downcase + ".rrd")
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
