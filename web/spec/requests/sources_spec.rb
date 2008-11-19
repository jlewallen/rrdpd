require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/sources" do
  before(:each) do
    @response = request("/sources")
  end
end