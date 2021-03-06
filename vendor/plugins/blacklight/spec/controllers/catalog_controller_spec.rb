require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'rubygems'
require 'marc'

describe CatalogController do
#=begin
  # ROUTES and MAPPING
  describe "Paths Generated by Custom Routes:" do
    # paths generated by custom routes
    it "should map {:controller => 'catalog', :id => '888', :action => 'email'} to /catalog/888/email" do
      route_for(:controller => 'catalog', :action => 'email', :id => '888').should == '/catalog/888/email'
    end
    it "should map {:controller => 'catalog', :id => '777', :action => 'sms'} to /catalog/777/sms" do
      route_for(:controller => 'catalog', :action => 'sms', :id => '777').should == '/catalog/777/sms'
    end
    it "should map { :controller => 'catalog', :action => 'show', :id => 666 } to /catalog/666" do
      route_for(:controller => 'catalog', :action => 'show', :id => '666').should == '/catalog/666'
    end
    it "should map {:controller => 'catalog', :id = '444', :action => 'image'} to /catalog/444/image" do
      route_for(:controller => 'catalog', :action => 'image', :id => '444').should == '/catalog/444/image'      
    end
    it "should map {:controller => 'catalog', :id = '333', :action => 'status'} to /catalog/333/status" do
      route_for(:controller => 'catalog', :action => 'status', :id => '333').should == '/catalog/333/status'          
    end
    it "should map {:controller => 'catalog', :id => '222', :action => 'availability'} to /catalog/222/availability" do
      route_for(:controller => 'catalog', :action => 'availability', :id => '222').should == '/catalog/222/availability'
    end

  end

  # parameters generated from routes
  describe "Parameters Generated from Routes:" do
    it "should map /catalog/888/email to {:controller => 'catalog', :action => 'email', :id => 888}" do
      params_from(:get, '/catalog/888/email').should == {:controller => 'catalog', :action => 'email', :id => '888'}
    end
    it "should map /catalog/777/sms to {:controller => 'catalog', :action => 'sms', :id => 777}" do
      params_from(:get, '/catalog/777/sms').should == {:controller => 'catalog', :action => 'sms', :id => '777'}
    end
    it "should map /catalog/666 to {:controller => 'catalog', :action => 'show', :id => 666}" do
      params_from(:get, '/catalog/666').should == {:controller => 'catalog', :action => 'show', :id => '666'}
    end
    it "should map /catalog/444/image to {:controller => 'catalog', :action => 'image', :id => 444}" do
      params_from(:get, '/catalog/444/image').should == {:controller => 'catalog', :action => 'image', :id => '444'}
    end
    it "should map /catalog/333/status to {:controller => 'catalog', :action => 'status', :id => 333}" do
      params_from(:get, '/catalog/333/status').should == {:controller => 'catalog', :action => 'status', :id => '333'}
    end
    it "should map /catalog/222/availability to {:controller => 'catalog', :action => 'availability', :id => 222}" do
      params_from(:get, '/catalog/222/availability').should == {:controller => 'catalog', :action => 'availability', :id => '222'}
    end
  end


  # INDEX ACTION
  describe "index action" do
    before(:each) do
      @user_query = 'book'  # query that will get results
      @no_docs_query = 'sadfdsafasdfsadfsadfsadf' # query for no results
      @facet_query = {"format_facet" => 'Book'}      
    end
    
    it "should have no search history if no search criteria" do
      session[:history] = []
      get :index
      session[:history].length.should == 0
    end
    
    # check each user manipulated parameter
    it "should have docs and facets for query with results" do
      get :index, :q => @user_query
      assigns[:response].docs.size.should > 1
      assert_facets_have_values(assigns[:response].facets)
    end
    it "should have docs and facets for existing facet value" do
      get :index, :f => @facet_query
      assigns[:response].docs.size.should > 1
      assert_facets_have_values(assigns[:response].facets)
    end
    it "should have docs and facets for non-default results per page" do
      num_per_page = 7
      get :index, :per_page => num_per_page
      assigns[:response].docs.size.should == num_per_page
      assert_facets_have_values(assigns[:response].facets)
    end
    
    it "should have docs and facets for second page" do
      page = 2
      get :index, :page => page
      assigns[:response].docs.size.should > 1
      assigns[:response].params[:start].to_i.should == (page-1) * Blacklight.config[:index][:num_per_page]
      assert_facets_have_values(assigns[:response].facets)
    end
    
    it "should have no docs or facet values for query without results" do
      get :index, :q => @no_docs_query
      assigns[:response].docs.size.should == 0
      assigns[:response].facets.each do |facet|
        facet.items.size.should == 0
      end
    end
    
    it "should have a spelling suggestion for an appropriately poor query" do
      get :index, :q => 'boo'
      assigns[:response].spelling.words.should_not be_nil      
    end
    
    describe "session" do
      it "should include :search key with hash" do
        get :index
        session[:search].should_not be_nil
        session[:search].should be_kind_of(Hash)
      end
      it "should include search hash with key :q" do
        get :index, :q => @user_query
        session[:search].should_not be_nil
        session[:search].keys.should include(:q)
        session[:search][:q].should == @user_query
      end
      it "should include search hash with key :f" do
        get :index, :f => @facet_query
        session[:search].should_not be_nil
        session[:search].keys.should include(:f)
        session[:search][:f].should == @facet_query
      end
      it "should include search hash with key :per_page" do
        get :index, :per_page => 10
        session[:search].should_not be_nil
        session[:search].keys.should include(:per_page)
        session[:search][:per_page].should == "10"
      end
      it "should include search hash with key :page" do
        get :index, :page => 2
        session[:search].should_not be_nil
        session[:search].keys.should include(:page)
        session[:search][:page].should == "2"
      end
    end

    # check with no user manipulation
    describe "for default query" do
      it "should get documents when no query" do
        get :index
        assigns[:response].docs.size.should > 1
      end
      it "should get facets when no query" do
        get :index
        assert_facets_have_values(assigns[:response].facets)
      end
    end

    it "should get rss feed" do
      get :index, :format => 'rss'
      response.should be_success      
    end

    it "should render index.html.erb" do
      get :index
      response.should render_template(:index)
    end    
    # NOTE: status code is always 200 in isolation mode ...
    it "HTTP status code for GET should be 200" do
      get :index
      response.should be_success
    end
    
  end # describe index action
  
  describe "update action" do
    doc_id = '2007020969'
    
    it "should set counter value into session[:search]" do
      put :update, :id => doc_id, :counter => 3
      session[:search][:counter].should == "3"
    end
    
    it "should redirect to show action for doc id" do
      put :update, :id => doc_id, :counter => 3
      assert_redirected_to(catalog_path(doc_id))
    end
  end

  # SHOW ACTION
  describe "show action" do

    doc_id = '2007020969'

    it "should get document" do
      get :show, :id => doc_id
      assigns[:document].should_not be_nil
    end
    it "should set previous document if counter present in session" do
      session[:search] = {:q => "", :counter => 2}
      get :show, :id => doc_id
      assigns[:previous_document].should_not be_nil
    end
    it "should not set previous document if counter is 1" do
      session[:search] = {:counter => 1}
      get :show, :id => doc_id
      assigns[:previous_document].should be_nil
    end
    it "should not set previous or next document if session is blank" do
      get :show, :id => doc_id
      assigns[:previous_document].should be_nil
      assigns[:next_document].should be_nil
    end
    it "should not set previous or next document if session[:search][:counter] is nil" do
      session[:search] = {:q => ""}
      get :show, :id => doc_id
      assigns[:previous_document].should be_nil
      assigns[:next_document].should be_nil
    end
    it "should set next document if counter present in session" do
      session[:search] = {:q => "", :counter => 2}
      get :show, :id => doc_id
      assigns[:next_document].should_not be_nil
    end
    it "should not set next document if counter is >= number of docs" do
      session[:search] = {:counter => 66666666}
      get :show, :id => doc_id
      assigns[:next_document].should be_nil
    end
    
    # NOTE: status code is always 200 in isolation mode ...
    it "HTTP status code for GET should be 200" do
      get :show, :id => doc_id
      response.should be_success
    end  
    it "should render show.html.erb" do
      get :show, :id => doc_id
      response.should render_template(:show)
    end
    
    describe "@document" do
      before(:each) do
        get :show, :id => doc_id
        @document = assigns[:document]
      end
      it "should be a SolrDocument" do
        @document.should be_instance_of(SolrDocument)
      end
    end

  end # describe show action

  describe "opensearch" do
    it "should return an opensearch description" do
      get :opensearch, :format => 'xml'
      response.should be_success
    end
    it "should return valid JSON" do
      get :opensearch,:format => 'json', :q => "a"
      response.should be_success
    end    
  end
#=end
  describe "send_email_record" do
    doc_id = '2007020969'
    describe "email" do
      it "should give error if no TO paramater" do
        post :send_email_record, :id => doc_id, :style => 'email'
        response.flash[:error].should == "You must enter a recipient in order to send this message"
      end
      it "should give an error if the email address is not valid" do
        post :send_email_record, :id => doc_id, :style => 'email', :to => 'test_bad_email'
        response.flash[:error].should == "You must enter a valid email address"
      end
      it "should not give error if no Message paramater is set" do
        post :send_email_record, :id => doc_id, :style => 'email', :to => 'test_email@projectblacklight.org'
        response.flash[:error].should be_nil
      end
      it "should redirect back to the record upon success" do
        post :send_email_record, :id => doc_id, :style => 'email', :to => 'test_email@projectblacklight.org'
        response.flash[:error].should be_nil
        response.should redirect_to(catalog_path(doc_id))
      end
    end
    describe "sms" do
      it "should give error if no phone number is given" do
        post :send_email_record, :id => doc_id, :style => 'sms', :carrier => 'att'
        response.flash[:error].should == "You must enter a recipient in order to send this message"
      end
      it "should give an error when a carrier is not provided" do
        post :send_email_record, :id => doc_id, :style => 'sms', :to => '5555555555', :carrier => ''
        response.flash[:error].should == "You must select a carrier"
      end
      it "should give an error when the phone number is not 10 digits" do
        post :send_email_record, :id => doc_id, :style => 'sms', :to => '555555555', :carrier => 'att'
        response.flash[:error].should == "You must enter a valid 10 digit phone number"
      end
      it "should redirect back to the record upon success" do
        post :send_email_record, :id => doc_id, :style => 'sms', :to => '5555555555', :carrier => 'att'
        response.flash[:error].should be_nil
        response.should redirect_to(catalog_path(doc_id))
      end
    end
  end

  
end


# there must be at least one facet, and each facet must have at least one value
def assert_facets_have_values(facets)
  facets.size.should > 1
  # should have at least one value for each facet
  facets.each do |facet|
    facet.items.size.should >= 1
  end
end