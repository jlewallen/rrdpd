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
