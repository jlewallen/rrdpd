#!/usr/bin/env ruby

class YesOrNo < RrdWriter
	def rollup(time, key, samples)
		counters = { :ok => 0, :fail => 0 }
		samples.each do |value|
			counters[value > 0 ? :ok : :fail] += 1
		end
		data = Struct.new(:time, :ok, :fail).new(time, counters[:ok], counters[:fail])
		save(key, data)
	end

	def save(key, data)
		file = get_rrd_file("yesno", key)
		if !Pathname.new(file).file? then
			command  = "create #{file} "
			command += " --step 10 "
			command += " --start 1211478990 "
			command += " DS:ok:GAUGE:600:0:U "
			command += " DS:fail:GAUGE:600:0:U "
			command += " RRA:AVERAGE:0.5:1:25920"    # 72 hours at 1 sample per 10 secs
			command += " RRA:AVERAGE:0.5:60:4320"    # 1 month at 1 sample per 10 mins
			command += " RRA:AVERAGE:0.5:2880:5475 " # 5 years at 1 sample per 8 hours
			rrd(command)
		end
		values = [ data.time, data.ok, data.fail ].map { |value| value.to_s }
		command = "update #{file} " + values.join(":")
		rrd(command)
	end
end
