class Welcome < Application

  def index
    @databases = DataManager.find_all
    display @databases
    render
  end
  
end
