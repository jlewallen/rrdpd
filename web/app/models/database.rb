class DatabaseOnDisk
	attr_reader :path
	attr_reader :source
	attr_reader :grapher
	attr_reader :name

	def initialize(grapher, source, name, path)
		@grapher = grapher
		@source = source
		@name = name
		@path = path
    @display_name = name
	end

  def display_name=(value)
    @display_name = value
  end

  def display_name
    @display_name
  end

	def unique_name
		@path.basename('.rrd').to_s
	end

  def uri(starting='1days', ending='now', w=600, h=200)
    Merb::Router.url(:render, :source => @source, :name => @name, :grapher => @grapher, :starting => starting, :ending => ending, :w => w, :h => h)
  end
end
