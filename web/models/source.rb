class Source
  DEFAULT_NAME = 'ALL'

  include Comparable

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def is_default
    @name =~ /ALL/i
  end

  def as_json(options={})
    {
      :name => @name
    }
  end

  def <=>(anOther)
    name <=> anOther.name
  end
end
