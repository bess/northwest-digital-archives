require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AddressesController do
  
  describe "POST create" do
  
    before(:each) do    
      @address = mock_model(Address, :save => nil) 
      Address.stub!(:new).and_return(@address) 
    end

    #Delete this example and add some real ones
    it "should use AddressesController" do
      controller.should be_an_instance_of(AddressesController)
    end
  
    it "should build a new address" do 
      Address.should_receive(:new). 
      with("name" => "Foley Center Library Special Collections"). 
      and_return(@address) 
      post :create, :address => { "name" => "Foley Center Library Special Collections" } 
    end 
  
    it "should save the address" do 
      @address.should_receive(:save) 
      post :create 
    end 
  end
  
  describe "index action" do
    fixtures :addresses
    
    before(:each) do
      get :index
      @addresses = assigns(:addresses)
    end
    
    it "should return an array" do
      @addresses.should be_instance_of(Array)
    end
    
    it "should find all three addresses" do
      @addresses.length.should == 3
    end
    
    
    
    
  end
  

  


end
