class Query < Application

  provides :json, :html

  def categorized
    @query = DataManager.find_categorized
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

  def item(category, name, source, counter)
    @query = DataManager.find_item(category, name).browser(source, counter.to_sym)
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

  def database(name)
    @query = DataManager.find_database_by_name(name)
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

  def graph(category, name, source, counter, starting)
    @query = DataManager.find_item(category, name).browser(source, counter.to_sym, { :starting => starting })
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

end
