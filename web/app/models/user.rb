class User
  if defined?(DataMapper)
    include DataMapper::Resource
    property :id,     Serial
    property :login,  String
  else
    attr_accessor :id, :login
  end
end
