class Render < Application

  only_provides :png

  def graph(source, event, grapher, starting, ending)
    dod = DataManager.find(source, event, grapher.to_sym)
    database = Struct.new(:path, :title).new(dod.path.to_s, dod.unique_name)
    grapher = graphers[dod.grapher]
    @image = grapher.graph(database, starting, ending)
    display @image
  end

  def graphers
    {
      :yesno => YesNoGrapher.new,
      :quartiles => QuartilesGrapher.new
    }
  end
  
end
