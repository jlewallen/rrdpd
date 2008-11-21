class Timespan
  attr_reader :name

  def initialize(name, uri)
    @name = name
    @uri = uri
  end

  def self.standard(dod)
    [
      Timespan.new('4weeks', dod.uri('4weeks', 'now')),
      Timespan.new('1weeks', dod.uri('1weeks', 'now')),
      Timespan.new('3days', dod.uri('3days', 'now')),
      Timespan.new('1day', dod.uri('1day', 'now')),
      Timespan.new('6hours', dod.uri('6hours', 'now'))
    ]
  end

  def to_json
    {
      :name => @name,
      :uri => @uri
    }.to_json
  end
end
