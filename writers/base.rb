#!/usr/bin/env/ruby

require 'logger'

class RrdWriter
	def initialize(cfg)
		@cfg = cfg
	end

	def get_rrd_file(name)
		return @cfg.data_directory + "/" + name.downcase + ".rrd"
	end

	def rrd(command)
		Configuration.log.debug(command)
		system("/usr/bin/rrdtool #{command}")
	end
end
