class DatabaseOnDisk
	attr_reader :path
  attr_reader :category
	attr_reader :source
	attr_reader :name
	attr_reader :counter

	def initialize(path, category, source, name, counter)
		@path = path
    @category = category
		@source = source
		@name = name
		@counter = counter
	end

	def unique_name
		@path.basename('.rrd').to_s
	end

  def uri(starting='1days', ending='now', w=600, h=200)
    Urls.url(:render, :source => @source, :name => @name, :counter => @counter, :starting => starting, :ending => ending, :w => w, :h => h)
  end
end
