require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  before(:each) do
    @valid_attributes = {
      :name => "Foley Center Library Special Collections",
      :institution => "Gonzaga University",
      :url => "http://www.foley.gonzaga.edu/spcoll/jopa.html",
      :city => "Spokane", 
      :state => "WA", 
      :postal_code => "99258",
      :phone_number => "(509) 313-3814"
      
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
  
  it "should be invalid without an institution" do
    @address.institution = nil
    @address.should_not be_valid
    @address.errors.on(:institution).should == "is required"
    @address.institution = "Gonzaga University"
    @address.should be_valid
  end
  
  it "should be invalid without a city" do
    @address.city = nil
    @address.should_not be_valid
    @address.errors.on(:city).should == "is required"
    @address.city = "Spokane"
    @address.should be_valid
  end
  
  it "should be invalid without a state" do
    @address.state = nil
    @address.should_not be_valid
    @address.errors.on(:state).should == "is required"
    @address.state = "WA"
    @address.should be_valid
  end

  it "should be invalid without a postal code" do
    @address.postal_code = nil
    @address.should_not be_valid
    @address.errors.on(:postal_code).should == "is required"
    @address.postal_code = "22902"
    @address.should be_valid
  end

end
