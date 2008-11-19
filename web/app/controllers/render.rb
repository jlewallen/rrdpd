class Render < Application

  only_provides :png

  def graph(source, event, grapher)
    found = DataManager.find(event)
    dod = found.database(source, grapher.to_sym)
    database = Struct.new(:path, :title).new(dod.path.to_s, dod.unique_name)
    grapher = graphers[dod.type]
    @image = grapher.graph(database)
    display @image
  end

  def graphers
    {
      :yesno => YesNoGrapher.new,
      :quartiles => QuartilesGrapher.new
    }
  end
  
end
