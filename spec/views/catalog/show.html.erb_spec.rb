require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper') 
#require File.expand_path(File.dirname(__FILE__) + '/../../../vendor/plugins/blacklight/app/helpers/application_helper') 

describe "catalog/show.html.erb" do 
  
  before(:each) do 
    @document_valid_attributes = { :collection_facet =>["Northwest Digital Archives EAD Guides"], 
      :unittitle_t=>["Summary Information"], 
      :hierarchy=>"Summary Information", 
      :availability_facet=>["Not online. Must visit contributing institution."], 
      :abstract_t=>["The materials consist of the papers of James O'Sullivan "], 
      :timestamp=>"2009-08-02T04:22:43.73Z", 
      :title_t=>"Guide to the", 
      :xml_display=>"<did id=\"a1\"> \n\t\t<repository> \n\t\t  <corpname encodinganalog=\"852$a\">Foley Center Library Special\n\t\t\t Collections</corpname><subarea encodinganalog=\"852$b\">Gonzaga\n\t\t  University</subarea> \n\t\t  <address> \n\t\t\t <addressline>Spokane, WA 99258</addressline> \n\t\t\t <addressline>(509) 313-3847</addressline> \n\t\t\t <addressline>http://www.foley.gonzaga.edu/spcoll</addressline> \n\t\t  </address></repository> \n\t\t<unitid countrycode=\"us\" encodinganalog=\"099\" repositorycode=\"WaSpG\">GU-1</unitid> \n\t\t<origination> \n\t\t  <persname encodinganalog=\"100\" role=\"creator\" rules=\"dacs\">O'Sullivan,\n\t\t\t James E., 1876-1949</persname></origination> \n\t\t<unittitle encodinganalog=\"245$a\" type=\"collection\">James O'Sullivan\n\t\t  Papers </unittitle> \n\t\t<unitdate era=\"ce\" calendar=\"gregorian\" encodinganalog=\"245$f\" type=\"inclusive\" normal=\"1903/1949\">1903-1949</unitdate> \n\t\t<unitdate era=\"ce\" calendar=\"gregorian\" encodinganalog=\"245$f\" type=\"bulk\" normal=\"1919/1948\">1919-1948</unitdate> \n\t\t<physdesc><extent encodinganalog=\"300$a\">36 linear feet (16\n\t\t  cartons)</extent>\n\t\t</physdesc>\n\t\t<abstract encodinganalog=\"5203_\">The materials consist of the papers of\n\t\t  James O'Sullivan while he was working on the building of the Grand Coulee Dam\n\t\t  in Washington State. There are correspondence, clippings, documents, and\n\t\t  photographs regarding the dam's construction.</abstract> \n\t\t<langmaterial encodinganalog=\"546\"><language langcode=\"eng\">English</language></langmaterial> \n\t </did>", 
      :institution_t=>["Foley Center Library Special Collections, Gonzaga University"], 
      :id=>"gu_1-summary", 
      :institution_facet=>"Foley Center Library Special Collections", 
      :institution_sort=>"Foley Center Library Special Collections", 
      :language_facet=>["English"], 
      :collection_id=>"gu_1", 
      :hierarchy_scope=>"gu_1", 
      :format_facet=>["ead"], 
      :format_code_t=>["ead"], 
      :filename_t=>["Gonzaga University/WUGGU_1.xml"]#}, @_source_mash={"unittitle_t"=>["Summary Information"], "collection_facet"=>["Northwest Digital Archives EAD Guides"], "abstract_t"=>["The materials consist of the papers of    James O'Sullivan while he was working on the building of the Grand Coulee Dam    in Washington State. There are correspondence, clippings, documents, and    photographs regarding the dam's construction."], "availability_facet"=>["Not online. Must visit contributing institution."], "hierarchy"=>"Summary Information", "timestamp"=>"2009-08-02T04:22:43.73Z", "institution_t"=>["Foley Center Library Special Collections, Gonzaga University"], "xml_display"=>"<did id=\"a1\"> \n\t\t<repository> \n\t\t  <corpname encodinganalog=\"852$a\">Foley Center Library Special\n\t\t\t Collections</corpname><subarea encodinganalog=\"852$b\">Gonzaga\n\t\t  University</subarea> \n\t\t  <address> \n\t\t\t <addressline>Spokane, WA 99258</addressline> \n\t\t\t <addressline>(509) 313-3847</addressline> \n\t\t\t <addressline>http://www.foley.gonzaga.edu/spcoll</addressline> \n\t\t  </address></repository> \n\t\t<unitid countrycode=\"us\" encodinganalog=\"099\" repositorycode=\"WaSpG\">GU-1</unitid> \n\t\t<origination> \n\t\t  <persname encodinganalog=\"100\" role=\"creator\" rules=\"dacs\">O'Sullivan,\n\t\t\t James E., 1876-1949</persname></origination> \n\t\t<unittitle encodinganalog=\"245$a\" type=\"collection\">James O'Sullivan\n\t\t  Papers </unittitle> \n\t\t<unitdate era=\"ce\" calendar=\"gregorian\" encodinganalog=\"245$f\" type=\"inclusive\" normal=\"1903/1949\">1903-1949</unitdate> \n\t\t<unitdate era=\"ce\" calendar=\"gregorian\" encodinganalog=\"245$f\" type=\"bulk\" normal=\"1919/1948\">1919-1948</unitdate> \n\t\t<physdesc><extent encodinganalog=\"300$a\">36 linear feet (16\n\t\t  cartons)</extent>\n\t\t</physdesc>\n\t\t<abstract encodinganalog=\"5203_\">The materials consist of the papers of\n\t\t  James O'Sullivan while he was working on the building of the Grand Coulee Dam\n\t\t  in Washington State. There are correspondence, clippings, documents, and\n\t\t  photographs regarding the dam's construction.</abstract> \n\t\t<langmaterial encodinganalog=\"546\"><language langcode=\"eng\">English</language></langmaterial> \n\t </did>", "title_t"=>"Guide to the James O'Sullivan   Papers    ", "institution_sort"=>"Foley Center Library Special Collections", "institution_facet"=>"Foley Center Library Special Collections", "id"=>"gu_1-summary", "language_facet"=>["English"], "filename_t"=>["Gonzaga University/WUGGU_1.xml"], "format_code_t"=>["ead"], "format_facet"=>["Archival Documents"], "hierarchy_scope"=>"gu_1", "collection_id"=>"gu_1"}
    }
    @document = @document_valid_attributes
    
    assigns[:document] = @document 
    @address = Address.find_by_name(@document[:institution_facet])
    assigns[:address] = @address
    
    # Mock some calls so we don't derail our tests when the partials don't render
    template.stub!(:render).with(hash_including(:partial => 'constraints'))
    template.stub!(:link_back_to_catalog)
    template.stub!(:render).with(hash_including(:partial => 'show_tools'))
    template.stub!(:render).with(hash_including(:partial => 'solr_request'))
  end 
  
  
  it "should display the title" do 
    render "catalog/show.html.erb" 
    response.should contain(@document[:title_t]) 
    # puts response.body    
  end 
  
  # it "should display the language_facet" do 
  #   render "catalog/show.html.erb" 
  #   response.should contain(@document[:language_facet]) 
  # end
  # 
  # it "should display the abstract" do 
  #   render "catalog/show.html.erb" 
  #   response.should contain(@document[:abstract]) 
  # end
  
end 
