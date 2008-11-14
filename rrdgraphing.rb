#!/usr/bin/env ruby

require 'pathname'
require 'rrdpd'

class Database
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
        yield Database.new($3.to_sym, $1, $2, path)
      end
    end
  end
end

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
    "AREA:#{@id}##{@color}" + (@stack ? ":STACK" : "")
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

graphers = {
  :yesno => YesNoGrapher.new,
  :quartiles => QuartilesGrapher.new
}

cfg = Configuration.new(Pathname.new("/home/jlewalle/rrdpd/data"))
Configuration.log = Logger.new(STDOUT)
Configuration.log.level = Logger::INFO
find = Finder.new(cfg)
find.databases do |database|
  grapher = graphers[database.type]
  grapher.graph(database, database.output_name)
end

# EOF
