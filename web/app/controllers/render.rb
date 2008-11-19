class Render < Application

  only_provides :png

  def graph
    database = Struct.new(:path, :title).new("/dev/shm/rrdpd-data/all-value-quartiles.rrd", "")
    grapher = QuartilesGrapher.new
    @image = grapher.graph(database)
    display @image
  end
  
end
