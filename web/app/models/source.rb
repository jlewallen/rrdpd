class Source
  DEFAULT_NAME = 'ALL'

  include Comparable
  
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def to_json
    { 
      :name => @name
    }.to_json
  end

  def <=>(anOther)
    name <=> anOther.name
  end
end
