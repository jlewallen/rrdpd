require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/events" do
  before(:each) do
    @response = request("/events")
  end
end