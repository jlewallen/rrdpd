require 'yaml'

class Configuration
  attr_reader :data
  attr_reader :categories
  attr_reader :web

  def initialize(data, web)
    @data = data
    @categories = [ CategoryDefinition.new('WWW', /^www-(.+)/) ]
    @web = web
  end

  def self.load(path)
    settings = YAML.load_file(path)
    @@cfg = Configuration.new(Pathname.new(settings['data']), WebConfiguration.new(settings['web']))
  end

  def self.global
    @@cfg
  end
end

class WebConfiguration
  attr_reader :username
  attr_reader :password

  def initialize(cfg)
    @username = cfg['username']
    @password = cfg['password']
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
