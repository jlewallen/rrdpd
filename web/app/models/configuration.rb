class Configuration
  attr_reader :data
  attr_reader :categories

  def initialize(data)
    @data = data
    @categories = [ CategoryDefinition.new('WWW', /^www-/) ]
  end
end

class CategoryDefinition
  attr_reader :name
  attr_reader :re

  def initialize(name, re)
    @name = name
    @re = re
  end
end
