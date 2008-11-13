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
  def initialize(time, name)
    @time = time
    @name = name
    @values = []
  end

  def add(message)
    @values << message.value
  end

  def rollup(writers)
    writers.each do |writer|
      writer.rollup(@time, @name, @values)
      Configuration.log.info(@name + " processed " + @values.length.to_s + " samples")
    end
  end
end

class Slice
  def initialize(time)
    @time = time
    @sets = {}
  end

  def add(message)
    key = message.name
    if !@sets.has_key?(key) then
      @sets[key] = SampleSet.new(@time, key)
    end
    @sets[key].add(message)
  end

  def rollup(writers)
    @sets.each do |key, value|
      value.rollup(writers)
    end
  end
end

# EOF
