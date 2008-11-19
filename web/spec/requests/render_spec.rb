require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/render" do
  before(:each) do
    @response = request("/render")
  end
end