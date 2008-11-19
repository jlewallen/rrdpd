require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a graph exists" do
  Graph.all.destroy!
  request(resource(:graphs), :method => "POST", 
    :params => { :graph => { :id => nil }})
end

describe "resource(:graphs)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:graphs))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of graphs" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a graph exists" do
    before(:each) do
      @response = request(resource(:graphs))
    end
    
    it "has a list of graphs" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Graph.all.destroy!
      @response = request(resource(:graphs), :method => "POST", 
        :params => { :graph => { :id => nil }})
    end
    
    it "redirects to resource(:graphs)" do
      @response.should redirect_to(resource(Graph.first), :message => {:notice => "graph was successfully created"})
    end
    
  end
end

describe "resource(@graph)" do 
  describe "a successful DELETE", :given => "a graph exists" do
     before(:each) do
       @response = request(resource(Graph.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:graphs))
     end

   end
end

describe "resource(:graphs, :new)" do
  before(:each) do
    @response = request(resource(:graphs, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@graph, :edit)", :given => "a graph exists" do
  before(:each) do
    @response = request(resource(Graph.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@graph)", :given => "a graph exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Graph.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @graph = Graph.first
      @response = request(resource(@graph), :method => "PUT", 
        :params => { :graph => {:id => @graph.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@graph))
    end
  end
  
end
