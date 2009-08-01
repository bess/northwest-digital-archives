require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  before(:each) do
    @valid_attributes = {
      :name => "Foley Center Library",
      :url => "http://www.foley.gonzaga.edu/spcoll/jopa.html"
      
    }
    #@address = Address.new
  end

  it "should create a new instance given valid attributes" do
    Address.create!(@valid_attributes)
  end

  # it "should be invalid without a name" do
  #   @address.should_not_be_valid
  #   @address.name = 'Foley Center Library'
  #   @address.should_be_valid
  # end


end
