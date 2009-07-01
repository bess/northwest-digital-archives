require 'nokogiri'

class EADSolrMapper
  
  attr :xml
  
  # file_id is used as a collection_id field backup, in case the eadid is missing...
  attr :file_id
  
  def initialize(doc_path)
    @file_id = val_to_id File.basename(doc_path, '.xml')
    raw = File.read doc_path
    # remove the default namespace,
    # otherwise every query needs a "default:" prefix,
    # and a namespace option -- is this problematic?
    raw.gsub!(/xmlns=".*"/, '')
    @xml = Nokogiri::XML(raw)
  end
  
  # returns an array of hashes, suitable for solr consumption...
  def map
    solr_docs = []
    solr_docs << create_summary_doc
    solr_docs << create_desc_item('bioghist', 'Biography/History')
    solr_docs << create_desc_item('scopecontent', 'Scope and Content')
    solr_docs << create_desc_item('arrangement', 'Arrangement')
    solr_docs << create_desc_item('fileplan', 'File Plan')
    solr_docs += create_item_docs
    solr_docs.compact
  end
  
  def val_to_id(v)
    v.downcase.underscore.gsub(/\W+/, '').gsub(/ /, '').gsub(/\.xml/, '').gsub(/^ +| $/, '')
  end
  
  # returns the text value of /ead/eadheader/eadid.
  # if that value is empty, the value if @file_id is used instead.
  # both values are filtered through the val_to_id method.
  def collection_id
    @collection_id ||= (
      n = val_to_id(@xml.at('/ead/eadheader/eadid').text)
      n.empty? ? @file_id : n
    )
  end
  
  #########
  protected
  #########
  
  # creates a base hash doc for each solr document
    
  def base_doc
    @base_doc ||= {
      :format_code_t => 'ead',
      :format_facet => 'EAD',
      :title_t => @xml.at('/ead/eadheader[1]/filedesc[1]/titlestmt[1]/titleproper[1]/text()').text.strip,
      :unittitle_t => (@xml.at('//archdesc[@level="collection"]/did/unittitle').text rescue 'N/A'),
      :institution_t => @xml.at('//publicationstmt/publisher/text()[1]').text.strip,
      :institution_facet => @xml.at('//repository//corpname/text()[1]').text.gsub(/\s+/," ").strip,
      :language_facet => getLanguages,
      :hierarchy_scope => self.collection_id,
      :collection_id => self.collection_id,
      :collection_facet => "Northwest Digital Archives EAD Guides"    
    }
  end
  
  # get all of the languages used in the EAD guide, not only the language in which the guide itself is encoded
  # normalize the language values, and only keep the unique ones
  def getLanguages
    a = []
    @xml.xpath('//language/text()').each do |lang|
      a << lang
    end
    a.collect! {|lang| lang.to_s.gsub('.','').gsub(',','').strip.capitalize}
    a.uniq
  end
  
  # generates an "id" based on the collection_id
  # cleans up the passed-in arg a bit too...
  def generate_id(v)
    @collection_id + '-' + v.downcase.gsub(/\/+/, '_').gsub(/;+|\.+/, '').gsub(/ /, '-')
  end
  
  # create the summary doc
  def create_summary_doc
    label = 'Summary Information'
    self.base_doc.merge({
      :xml_display => @xml.at("/ead/archdesc/did").to_xml,
      :id => generate_id('summary'),
      :unittitle_t => label,
      :hierarchy => label
    })
  end
  
  # creates a /ead/archdesc based doc
  def create_desc_item(node_name, id_suffix)
    
    puts "node_name = #{node_name}"
    puts "id_suffix = #{id_suffix}"
    
    node = @xml.at('/ead/archdesc/' + node_name)
    return unless node
    label = node.at('head').text.capitalize rescue id_suffix.to_s
    self.base_doc.merge({
      :xml_display => node.to_xml,
      :id => generate_id(id_suffix),
      :unittitle_t => label,
      :hierarchy => label
    })
  end
  
  # creates an array of ead/archdesc/dsc/c docs
  def create_item_docs
    i=0
    @xml.search('ead/archdesc/dsc/c01[@level="series"]').inject([]) do |docs,s|
      puts "mapping c01 ##{i}"
      label = s.at('did/unittitle').text.capitalize
      rel_id = s.at('did/unitid').text rescue ("item-#{i}")
      i += 1
      docs << self.base_doc.merge({
        :id => generate_id(rel_id),
        :xml_display => s.to_xml,
        :unittitle_t => label,
        :hierarchy => "Collection Inventory::#{label}"
      })
    end
  end
  
end