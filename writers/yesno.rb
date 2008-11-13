#!/usr/bin/env ruby

class YesOrNo < RrdWriter
	def rollup(time, name, samples)
		counters = { :ok => 0, :fail => 0 }
		samples.each do |value|
			counters[value > 0 ? :ok : :fail] += 1
		end
		data = Struct.new(:time, :name, :ok, :fail).new(time, name, counters[:ok], counters[:fail])
		save(data)
	end

	def save(data)
		rrdfile = get_rrd_file("yesno-" + data.name)
		if !Pathname.new(rrdfile).file? then
			command  = "create #{rrdfile} "
			command += " --step 10 "
			command += " --start 1211478990 "
			command += " DS:ok:GAUGE:600:0:U "
			command += " DS:fail:GAUGE:600:0:U "
			command += " RRA:AVERAGE:0.5:1:8640 "    # 24 hours at 1 sample per 10 secs
			command += " RRA:AVERAGE:0.5:90:2880 "   # 1 month at 1 sample per 15 mins
			command += " RRA:AVERAGE:0.5:2880:5475 " # 5 years at 1 sample per 8 hours
			rrd(command)
		end
		values = [ data.time, data.ok, data.fail ].map { |value| value.to_s }
		command = "update #{rrdfile} " + values.join(":")
		rrd(command)
	end
end
