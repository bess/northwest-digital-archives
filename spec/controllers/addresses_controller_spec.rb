require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AddressesController do
  
  # values from the first fixture
  id1 = 1
  name1 = "Foley Center Library Special Collections"
  
  # create by POST
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
      with("name" => name1). 
      and_return(@address) 
      post :create, :address => { "name" => name1 } 
    end 
  
    it "should save the address" do 
      @address.should_receive(:save) 
      post :create 
    end 
  end
  
  # index action 
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
      @addresses.length.should == 4
    end
    
    # show action
    describe "show action" do
      fixtures :addresses
      
      it "finds an address by id" do
        get :show, :id => id1
        @address = assigns(:address)
        @address.should_not be_nil
        @address.name.should == name1
      end
      
      it "finds an address by name" do
        get :show, :name => name1
        @address = assigns(:address)
        @address.should_not be_nil
        @address.id.should == id1
      end
    end
    
    
    
    
  end
  

  


end
