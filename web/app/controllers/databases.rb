class Databases < Application
  # provides :xml, :yaml, :js

  def index
    @databases = Database.all
    display @databases
  end

  def show(id)
    @database = Database.get(id)
    raise NotFound unless @database
    display @database
  end

  def new
    only_provides :html
    @database = Database.new
    display @database
  end

  def edit(id)
    only_provides :html
    @database = Database.get(id)
    raise NotFound unless @database
    display @database
  end

  def create(database)
    @database = Database.new(database)
    if @database.save
      redirect resource(@database), :message => {:notice => "Database was successfully created"}
    else
      message[:error] = "Database failed to be created"
      render :new
    end
  end

  def update(id, database)
    @database = Database.get(id)
    raise NotFound unless @database
    if @database.update_attributes(database)
       redirect resource(@database)
    else
      display @database, :edit
    end
  end

  def destroy(id)
    @database = Database.get(id)
    raise NotFound unless @database
    if @database.destroy
      redirect resource(:databases)
    else
      raise InternalServerError
    end
  end

end # Databases
