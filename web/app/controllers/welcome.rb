class Welcome < Application

  def index
    @databases = DatabaseDataManager.find_all
    display @databases
    render
  end
  
end
