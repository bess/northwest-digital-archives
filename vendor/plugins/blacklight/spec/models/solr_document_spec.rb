require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'rubygems'
require 'marc'

# WARNING!!!
# If you set any values in Blacklight here, you must reset them to the original
# values in an after() block so other tests get expected results. 
# Blacklight is a Singleton for application configuration.

def get_hash_with_marcxml
  {'responseHeader'=>{'status'=>0,'QTime'=>0,'params'=>{'q'=>'id:00282214','wt'=>'ruby'}},'response'=>{'numFound'=>1,'start'=>0,'docs'=>[{'id'=>'00282214', Blacklight.config[:raw_storage_field] =>'<record xmlns=\'http://www.loc.gov/MARC21/slim\'><leader>00799cam a2200241 a 4500</leader><controlfield tag=\'001\'>   00282214 </controlfield><controlfield tag=\'003\'>DLC</controlfield><controlfield tag=\'005\'>20090120022042.0</controlfield><controlfield tag=\'008\'>000417s1998    pk            000 0 urdo </controlfield><datafield tag=\'010\' ind1=\' \' ind2=\' \'><subfield code=\'a\'>   00282214 </subfield></datafield><datafield tag=\'025\' ind1=\' \' ind2=\' \'><subfield code=\'a\'>P-U-00282214; 05; 06</subfield></datafield><datafield tag=\'040\' ind1=\' \' ind2=\' \'><subfield code=\'a\'>DLC</subfield><subfield code=\'c\'>DLC</subfield><subfield code=\'d\'>DLC</subfield></datafield><datafield tag=\'041\' ind1=\'1\' ind2=\' \'><subfield code=\'a\'>urd</subfield><subfield code=\'h\'>snd</subfield></datafield><datafield tag=\'042\' ind1=\' \' ind2=\' \'><subfield code=\'a\'>lcode</subfield></datafield><datafield tag=\'050\' ind1=\'0\' ind2=\'0\'><subfield code=\'a\'>PK2788.9.A9</subfield><subfield code=\'b\'>F55 1998</subfield></datafield><datafield tag=\'100\' ind1=\'1\' ind2=\' \'><subfield code=\'a\'>Ayaz, Shaikh,</subfield><subfield code=\'d\'>1923-1997.</subfield></datafield><datafield tag=\'245\' ind1=\'1\' ind2=\'0\'><subfield code=\'a\'>Fikr-i Ayāz /</subfield><subfield code=\'c\'>murattibīn, Āṣif Farruk̲h̲ī, Shāh Muḥammad Pīrzādah.</subfield></datafield><datafield tag=\'260\' ind1=\' \' ind2=\' \'><subfield code=\'a\'>Karācī :</subfield><subfield code=\'b\'>Dāniyāl,</subfield><subfield code=\'c\'>[1998]</subfield></datafield><datafield tag=\'300\' ind1=\' \' ind2=\' \'><subfield code=\'a\'>375 p. ;</subfield><subfield code=\'c\'>23 cm.</subfield></datafield><datafield tag=\'546\' ind1=\' \' ind2=\' \'><subfield code=\'a\'>In Urdu.</subfield></datafield><datafield tag=\'520\' ind1=\' \' ind2=\' \'><subfield code=\'a\'>Selected poems and articles from the works of renowned Sindhi poet; chiefly translated from Sindhi.</subfield></datafield><datafield tag=\'700\' ind1=\'1\' ind2=\' \'><subfield code=\'a\'>Farruk̲h̲ī, Āṣif,</subfield><subfield code=\'d\'>1959-</subfield></datafield><datafield tag=\'700\' ind1=\'1\' ind2=\' \'><subfield code=\'a\'>Pīrzādah, Shāh Muḥammad.</subfield></datafield></record>','timestamp'=>'2009-03-26T18:15:31.074Z','material_type_t'=>['375 p'],'title_t'=>['Fikr-i Ayāz'],'author_t'=>['Farruk̲h̲ī, Āṣif','Pīrzādah, Shāh Muḥammad'],'language_facet'=>['Urdu'],'format_code_t'=>['book'],'published_t'=>['Karācī'],'format_facet'=>['Book']}]}}
end
def get_hash_without_marcxml
  {'responseHeader'=>{'status'=>0,'QTime'=>0,'params'=>{'q'=>'id:00282214','wt'=>'ruby'}},'response'=>{'numFound'=>1,'start'=>0,'docs'=>[{'id'=>'00282214','timestamp'=>'2009-03-26T18:15:31.074Z','material_type_t'=>['375 p'],'title_t'=>['Fikr-i Ayāz'],'author_t'=>['Farruk̲h̲ī, Āṣif','Pīrzādah, Shāh Muḥammad'],'language_facet'=>['Urdu'],'format_code_t'=>['book'],'published_t'=>['Karācī'],'format_facet'=>['Book']}]}}
end

def get_hash_with_marc21
  reader = MARC::Reader.new(File.dirname(__FILE__) + '/../data/test_data.utf8.mrc')
  # doing weird i= stuff to get only first record.  reader.first, or i = 0, i+1 didn't work and this was the only way I could get it working.  Needs refactoring.
  i = "1st"
  for record in reader
   if i == "1st"
     first_rec = record.to_marc
   end
   i = "not1st"
  end
  {'responseHeader'=>{'status'=>0,'QTime'=>0,'params'=>{'q'=>'id:00282214','wt'=>'ruby'}},'response'=>{'numFound'=>1,'start'=>0,'docs'=>[{'id'=>'00282214', Blacklight.config[:raw_storage_field] => first_rec, 'timestamp'=>'2009-03-26T18:15:31.074Z','material_type_t'=>['375 p'],'title_t'=>['Fikr-i Ayāz'],'author_t'=>['Farruk̲h̲ī, Āṣif','Pīrzādah, Shāh Muḥammad'],'language_facet'=>['Urdu'],'format_code_t'=>['book'],'published_t'=>['Karācī'],'format_facet'=>['Book']}]}}
end

  describe SolrDocument do
    
    before(:all) do
      @hash_with_marcxml = get_hash_with_marcxml['response']['docs'][0]
      SolrDocument.marc_source_field  = :marc_display
      SolrDocument.marc_format_type   = :marcxml
      @solrdoc = SolrDocument.new(@hash_with_marcxml)
    end
    
    describe "new" do
      it "should take a Hash as the argument" do
        lambda { SolrDocument.new(@hash_with_marcxml) }.should_not raise_error(ArgumentError)
      end
    end
    
    describe "access methods" do
      
      it "should have the right value for format_facet" do
        @solrdoc[:format_facet][0].should == 'Book'
      end
      
      it "should provide the item's solr id" do
        @solrdoc.id.should == '00282214'
      end
      
      it "should have a _source_hash method that returns a Hash" do
        @solrdoc._source_hash.should be_instance_of(Hash)
      end

      it "should have access methods for all special function fields named in initializer" do
        # the fields specified in Blacklight.config[:show] that
        Blacklight.config[:show].each_key do |function| 
          @solrdoc[Blacklight.config[:show][function]].should_not be_nil
        end
      end
      
    end
    
    describe "marc attribute" do
 
      it "should have a valid storage field instatiated with an object" do
        #When we have more than marc, this will need to test each type.
        @solrdoc.marc.should be_instance_of(Blacklight::Marc::Document)
      end
      
      it "should not try to create marc for objects w/out stored marc (marcxml test only at this time)" do
        # TODO: Create another mock object that does not have marc-xml in it and make
        # sure everything fails gracefully
        @hash_without_marcxml = get_hash_without_marcxml['response']['docs'][0]
        @solrdoc_without_marc = SolrDocument.new(@hash_without_marcxml)
        @solrdoc_without_marc.marc.should be(nil)
      end
    end
    
    describe 'the search method' do
      
      it 'should use the default params from SolrDocument.default_params[:search]' do
        expected_params = {:facets=>{:fields=>["language_facet", "subject_era_facet", "geographic_subject_facet", "format_facet"]}, :q=>"tibet", :qt=>:search, :per_page=>10}
        response = SolrDocument.search(:q=>'tibet') do |params|
          params.should == expected_params
        end
      end
      
      it 'should return docs that are SolrDocument objects' do
        response = SolrDocument.search(:q=>'tibet')
        response.docs.each{|d| d.should be_instance_of(SolrDocument) }
      end
      
    end
    
    describe 'the find_by_id method' do
      
      it 'should use the default params from SolrDocument.default_params[:find_by_id]' do
        expected_params = {:qt=>:document, :rows=>1, :id=>'2008308202'}
        SolrDocument.find_by_id(:id=>'2008308202') do |params|
          params.should == expected_params
        end
      end
      
    end
    
    describe 'the merge_defaults method; which uses defaults from SolrDocument.default_params' do
      
      it 'should not allow blank values to override defaults' do
        p = SolrDocument.merge_defaults :search, :qt=>''
        p[:qt].should == :search
      end
      
      it 'should allow non-blank values to override the defaults' do
        p = SolrDocument.merge_defaults :search, :qt=>'abc'
        p[:qt].should == 'abc'
      end
      
    end
    
end