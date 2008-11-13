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
end

class Message
  attr_reader :name
  attr_reader :value

  def initialize(name, value)
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

class Slice
  def initialize(time)
    @time = time
    @samples = {}
  end

  def add(message)
    key = message.name
    if !@samples.has_key?(key) then
      @samples[key] = []
    end
    @samples[key] << message.value
  end

  def rollup(writers)
    writers.each do |writer|
      @samples.each do |key, value|
        writer.rollup(@time, key, value)
      end
    end
  end
end

# EOF
