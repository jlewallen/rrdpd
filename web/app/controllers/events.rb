class Events < Application

  provides :json, :html

  def categorized
    @categories = DataManager.find_categorized
    @categories.instance_eval "def to_html; '<p>' + to_json + '</p>'; end"
    display @categories
  end
  
end
