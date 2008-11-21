class CounterType
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
    name.to_s <=> anOther.name.to_s
  end
end
