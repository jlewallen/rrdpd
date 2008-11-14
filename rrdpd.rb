#!/usr/bin/env ruby

require 'pathname'
require 'writers/base.rb'
require 'writers/yesno.rb'
require 'writers/quartiles.rb'

class Configuration
  attr_reader :seconds_per_slice
  attr_reader :data_directory

  def initialize(seconds_per_slice=10, data_directory="/tmp")
    @seconds_per_slice = seconds_per_slice
    @data_directory = data_directory
  end

  def Configuration.log=(log)
    @@log = log
  end

  def Configuration.log
    @@log
  end
end

class SampleSetKey
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def to_sym
    @name.to_sym
  end

  def to_s
    @name
  end

  def eql?(o)
    o.is_a?(SampleSetKey) && @name == o.name
  end
  
  def hash
    @name.hash
  end
end

class Message
  attr_reader :source
  attr_reader :name
  attr_reader :value

  def initialize(source, name, value)
    @source = source
    @name = name
    @value = value
  end
end

class Slices
  def initialize(cfg, writers)
    @slices = {}
    @cfg = cfg
    @writers = writers
  end

  def add(message)
    get_slice.add(message)
  end

  def rollup(force=false)
    get_closed_slices(force).each do |slice|
      slice.rollup(@writers)
    end
  end

  private
  def get_closed_slices(force)
    open = get_slice_number
    closed = []
    @slices.delete_if do |key, value|
      closing = (key < open) || force
      if closing then
        closed << value
      end
      closing
    end
    closed
  end

  def get_slice_number
    (Time.now.to_i / @cfg.seconds_per_slice).floor
  end

  def get_slice
    number = get_slice_number
    if !@slices.has_key?(number) then
      @slices[number] = Slice.new(number * @cfg.seconds_per_slice)
    end
    @slices[number]
  end
end

class SampleSet
  def initialize(time, key)
    @time = time
    @key = key
    @values = []
  end

  def add(message)
    @values << message.value
  end

  def rollup(writers)
    writers.each do |writer|
      writer.rollup(@time, @key.to_s, @values)
      Configuration.log.info(writer.class.name + " " + @key.to_s + " processed " + @values.length.to_s + " samples")
    end
  end
end

class Slice
  def initialize(time)
    @time = time
    @sets = { }
  end

  def add(message)
    key = SampleSetKey.new(message.name)
    get(key).add(message)
  end

  def rollup(writers)
    @sets.each do |key, value|
      value.rollup(writers)
    end
  end
  
  private
  def get(key)
    if !@sets.has_key?(key) then
      @sets[key] = SampleSet.new(@time, key)
    end
    @sets[key]
  end
end

# EOF
