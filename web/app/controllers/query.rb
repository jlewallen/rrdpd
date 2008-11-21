class Query < Application

  provides :json, :html

  def categorized
    @query = DataManager.find_categorized
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

  def source(name)
    @query = DataManager.find_source(name)
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

  def item(category, name)
    @query = DataManager.find_item(category, name)
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

  def database(name)
    @query = DataManager.find_database_by_name(name)
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

  def graph(source, name, grapher, starting, ending, w, h)
  end

end
