require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper') 
describe "addresses/show.html.erb" do 
  before(:each) do 
    @valid_attributes = {
      :name => "Foley Center Library Special Collections",
      :institution => "Gonzaga University",
      :url => "http://www.foley.gonzaga.edu/spcoll/jopa.html",
      :street => "Fake Street",
      :city => "Spokane", 
      :state => "WA", 
      :postal_code => "99258",
      :phone_number => "(509) 313-3814"
    }
    @address = Address.create!(@valid_attributes)    
    assigns[:address] = @address 
  end 
  
  
  it "should display the name" do 
    render "addresses/show.html.erb" 
    response.should contain(@address.name) 
  end 
  
  it "should display the institution" do 
    render "addresses/show.html.erb" 
    response.should contain(@address.institution) 
  end
  
  it "should display the url" do
    render "addresses/show.html.erb" 
    response.should contain(@address.url) 
  end
  
  it "should display the street" do
    render "addresses/show.html.erb" 
    response.should contain(@address.street) 
  end
  
  it "should display the city" do
    render "addresses/show.html.erb" 
    response.should contain(@address.city) 
  end
  
  it "should display the state" do
    render "addresses/show.html.erb" 
    response.should contain(@address.state) 
  end
  
  it "should display the postal_code" do
    render "addresses/show.html.erb" 
    response.should contain(@address.postal_code) 
  end
  
  it "should display the phone_number" do
    render "addresses/show.html.erb" 
    response.should contain(@address.phone_number) 
  end
end 
