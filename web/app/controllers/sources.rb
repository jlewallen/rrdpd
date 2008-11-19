class Sources < Application

  def view
    @source = DataManager.find_source(params[:name])
    display @source
    render
  end
  
end
