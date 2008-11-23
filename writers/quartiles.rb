#!/usr/bin/env ruby

class Quartiles < RrdWriter
	def rollup(time, key, samples)
		return if samples.length < 2
		samples = samples.map { |x| x.to_i }
		samples = samples.sort
		lo = samples[0]
		hi = samples[samples.length - 1]
		number = samples.length
		lo_c = (number / 2).floor
		hi_c = number - lo_c

		ctor = Struct.new(:time, :lo, :q1, :q2, :q3, :hi, :total)
		data = ctor.new(time, 0, 0, 0, 0, 0, 0)

		if lo_c > 0 && hi_c > 0 then
			lo_samples = samples.slice(0, lo_c)
			hi_samples = samples.slice(lo_c, hi_c)
			lo_sum = 0
			hi_sum = 0
			lo_samples.each { |value| lo_sum += value }
			hi_samples.each { |value| hi_sum += value }
			q1 = lo_sum / lo_c
			q2 = (lo_sum + hi_sum) / (lo_c + hi_c)
			q3 = hi_sum / hi_c
			data.lo = lo
			data.q1 = q1
			data.q2 = q2
			data.q3 = q3
			data.hi = hi
			data.total = number
		end

		save(key, data)
	end

	def save(key, data)
		file = get_rrd_file("quartiles", key)
		if !Pathname.new(file).file? then
			command  = "create #{file} "
			command += " --step 10 "
			command += " --start 1211478990 "
			command += " DS:q1:GAUGE:600:0:U "
			command += " DS:q2:GAUGE:600:0:U "
			command += " DS:q3:GAUGE:600:0:U "
			command += " DS:lo:GAUGE:600:0:U "
			command += " DS:hi:GAUGE:600:0:U "
			command += " DS:total:GAUGE:600:0:U "
			command += " RRA:AVERAGE:0.5:1:25920"    # 72 hours at 1 sample per 10 secs
			command += " RRA:AVERAGE:0.5:60:4320"    # 1 month at 1 sample per 10 mins
			command += " RRA:AVERAGE:0.5:2880:5475 " # 5 years at 1 sample per 8 hours
			rrd(command)
		end
		values = [ data.time, data.q1, data.q2, data.q3, data.lo, data.hi, data.total ].map { |value| value.to_s }
		command = "update #{file} " + values.join(":")
		rrd(command)
	end
end

class FalseClass
	def to_i
		0
	end
end

class TrueClass
	def to_i
		1
	end
end

