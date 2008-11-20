class Configuration
  attr_reader :data
  attr_reader :categories

  def initialize(data)
    @data = data
    @categories = [ CategoryDefinition.new('WWW', /^www-(.+)/) ]
  end
end

class CategoryDefinition
  attr_reader :name

  def initialize(name, re)
    @name = name
    @re = re
  end

  def transform(name)
    if @re.match(name)  then
      return $1
    else
      return nil
    end
  end
end
