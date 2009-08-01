require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  before(:each) do
    @valid_attributes = {
      :name => "Foley Center Library",
      :url => "http://www.foley.gonzaga.edu/spcoll/jopa.html"
      
    }
    @address = Address.create!(@valid_attributes)
  end

  it "should create a new instance given valid attributes" do
    a = Address.create!(@valid_attributes)
    a.should be_valid
  end

  it "should be invalid without a name" do
    @address.name = nil
    @address.should_not be_valid
    @address.errors.on(:name).should == "is required"
    @address.name = 'Foley Center Library'
    @address.should be_valid
  end
  
  it "should be invalid without a url" do
    @address.url = nil
    @address.should_not be_valid
    @address.errors.on(:url).should == "is required"
    @address.url = 'http://www.foley.gonzaga.edu/spcoll/jopa.html'
    @address.should be_valid
  end


end
