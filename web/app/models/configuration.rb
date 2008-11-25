class Configuration
  attr_reader :data
  attr_reader :categories
  attr_reader :username
  attr_reader :password

  def initialize(data)
    @data = data
    @categories = [ CategoryDefinition.new('WWW', /^www-(.+)/) ]
    @username = 'admin'
    @password = 'admin'
  end

  def self.global=(value)
    @@cfg = value
  end

  def self.global
    @@cfg
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
