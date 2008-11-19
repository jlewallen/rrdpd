class Database
  include DataMapper::Resource
  
  property :id, Serial
  property :url, String
  property :path, String
end
