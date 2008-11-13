#!/usr/bin/env ruby

require 'pathname'
require 'rrdpd'

class Database
  attr_reader :type
  attr_reader :name
  attr_reader :path

  def initialize(type, name, path)
    @type = type
    @name = name
    @path = path
  end
end

class Finder
  def initialize(cfg)
    @cfg = cfg
  end

  def databases(&blk)
    Dir[@cfg.data_directory + "/*.rrd"].each do |file|
      path = Pathname.new(file)
      if path.basename.to_s =~ /^(.+)-(.+)\.rrd$/ then
        yield Database.new($1.to_sym, $2, path)
      end
    end
  end
end

cfg = Configuration.new
Configuration.log = Logger.new(STDOUT)
Configuration.log.level = Logger::INFO
find = Finder.new(cfg)
find.databases do |database|
  p database
end

# EOF
