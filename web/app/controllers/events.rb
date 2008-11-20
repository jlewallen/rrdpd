class Events < Application

  provides :json, :html

  def categorized
    @query = DataManager.find_categorized
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

  def item(name)
    @query = DataManager.find_item(name)
    @query.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @query
  end

end
