class Welcome < Application

  def index
    @sources = DataManager.find_sources
    display @sources
    render
  end
  
end
