class DatabaseOnDisk
	attr_reader :path
  attr_reader :category
	attr_reader :source
	attr_reader :name
	attr_reader :grapher

	def initialize(path, category, source, name, grapher)
		@path = path
    @category = category
		@source = source
		@name = name
		@grapher = grapher
	end

	def unique_name
		@path.basename('.rrd').to_s
	end

  def uri(starting='1days', ending='now', w=600, h=200)
    Merb::Router.url(:render, :source => @source, :name => @name, :grapher => @grapher, :starting => starting, :ending => ending, :w => w, :h => h)
  end
end
