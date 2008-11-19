class Graphs < Application
  # provides :xml, :yaml, :js

  def index
    @graphs = Graph.all
    display @graphs
  end

  def show(id)
    @graph = Graph.get(id)
    raise NotFound unless @graph
    display @graph
  end

  def new
    only_provides :html
    @graph = Graph.new
    display @graph
  end

  def edit(id)
    only_provides :html
    @graph = Graph.get(id)
    raise NotFound unless @graph
    display @graph
  end

  def create(graph)
    @graph = Graph.new(graph)
    if @graph.save
      redirect resource(@graph), :message => {:notice => "Graph was successfully created"}
    else
      message[:error] = "Graph failed to be created"
      render :new
    end
  end

  def update(id, graph)
    @graph = Graph.get(id)
    raise NotFound unless @graph
    if @graph.update_attributes(graph)
       redirect resource(@graph)
    else
      display @graph, :edit
    end
  end

  def destroy(id)
    @graph = Graph.get(id)
    raise NotFound unless @graph
    if @graph.destroy
      redirect resource(:graphs)
    else
      raise InternalServerError
    end
  end

end # Graphs
