class Events < Application

  only_provides :json

  def categorized
    @categories = DataManager.find_categorized
    display @categories
  end
  
end
