#!/usr/bin/env ruby

require 'pathname'

class Definition
	def initialize(id, database, name, rra="AVERAGE")
		@id = id
		@database = database
		@name = name
		@rra = rra
	end

	def to_s
		"DEF:#{@id}=#{@database.path.to_s}:#{@name}:#{@rra}"
	end
end

class Area
	def initialize(id, color, stack=false)
		@id = id
		@color = color
		@stack = stack
	end

	def to_s
		"AREA:#{@id}##{@color}" + (@stack ? "::STACK" : "")
	end
end

class Line
	def initialize(id, color)
		@id = id
		@color = color
	end

	def to_s
		"LINE1:#{@id}##{@color}"
	end
end

class Grapher
	def graph(database, destiny)
		parts = []
		parts << "/usr/bin/rrdtool graph"
		parts << destiny
		parts << "-w 600"
		parts << "-h 250"
		parts << "--start -3hours"
		parts << "--end now"
		parts << "--title \"#{database.unique_name}\""
		get_parts(database).each do |p|
			parts << p
		end
		joined = parts.map { |p| p.to_s }.join(" ")
		p joined
		system(joined)
	end

	def get_parts(database)
		[]
	end
end

class YesNoGrapher < Grapher
	def get_parts(database)
		[
			Definition.new("ok", database, "ok"),
			Definition.new("fail", database, "fail"),
			Area.new("ok", "AAFFAA", true),
			Area.new("fail", "FFAAAA", true),
			Line.new("ok", "737373")
		]
	end
end

class QuartilesGrapher < Grapher
	def get_parts(database)
		[
			Definition.new("lo", database, "lo"),
			Definition.new("hi", database, "hi"),
			Definition.new("q1", database, "q1"),
			Definition.new("q2", database, "q2"),
			Definition.new("q3", database, "q3"),
			Area.new("q3", "FFAAAA"),
			Area.new("q2", "AAFFAA"),
			Area.new("q1", "DDFFDD"),
			Area.new("lo", "FFFFFF"),
			Line.new("q2", "797979")
		]
	end
end

# EOF
