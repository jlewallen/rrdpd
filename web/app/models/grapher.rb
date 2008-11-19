class GraphImage
  def initialize(data)
    @data = data
  end

  def to_png
    @data
  end
end

class Grapher
	def graph(database)
		parts = []
		parts << "/usr/bin/rrdtool graph"
		parts << "-"
		parts << "-w 600"
		parts << "-h 250"
		parts << "--start -3hours"
		parts << "--end now"
		parts << "--title \"#{database.title}\""
		get_parts(database).each do |p|
			parts << p
		end
		joined = parts.map { |p| p.to_s }.join(" ")
		IO.popen(joined) do |f|
      return GraphImage.new(f.read)
    end
    null
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
