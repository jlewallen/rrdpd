require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a database exists" do
  Database.all.destroy!
  request(resource(:databases), :method => "POST", 
    :params => { :database => { :id => nil }})
end

describe "resource(:databases)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:databases))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of databases" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a database exists" do
    before(:each) do
      @response = request(resource(:databases))
    end
    
    it "has a list of databases" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Database.all.destroy!
      @response = request(resource(:databases), :method => "POST", 
        :params => { :database => { :id => nil }})
    end
    
    it "redirects to resource(:databases)" do
      @response.should redirect_to(resource(Database.first), :message => {:notice => "database was successfully created"})
    end
    
  end
end

describe "resource(@database)" do 
  describe "a successful DELETE", :given => "a database exists" do
     before(:each) do
       @response = request(resource(Database.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:databases))
     end

   end
end

describe "resource(:databases, :new)" do
  before(:each) do
    @response = request(resource(:databases, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@database, :edit)", :given => "a database exists" do
  before(:each) do
    @response = request(resource(Database.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@database)", :given => "a database exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Database.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @database = Database.first
      @response = request(resource(@database), :method => "PUT", 
        :params => { :database => {:id => @database.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@database))
    end
  end
  
end

