require 'nokogiri'

class EADSolrMapper
  
  attr :xml
  
  # file_id is used as a collection_id field backup, in case the eadid is missing...
  attr :file_id
  attr :filename
  attr :base_filename
  
  def initialize(doc_path)
    @filename = doc_path
    @file_id = val_to_id File.basename(doc_path, '.xml')
    @base_filename = @filename.split('/').slice(-2..-1).join('/')
    
    raw = File.read doc_path
    # remove the default namespace,
    # otherwise every query needs a "default:" prefix,
    # and a namespace option -- is this problematic?
    raw.gsub!(/xmlns=".*"/, '')
    @xml = Nokogiri::XML(raw)
  end
  
  # removes newlines, tabs, multiple spaces and beginning/trailing spaces.
  # if the argument is an Array, each item in the array is processed recursively.
  def to_one_line(v)
    v.is_a?(Array) ? v.map{|vv|to_one_line(vv)} : v.to_s.gsub(/\n+|\t+/, '').gsub(/ +/, ' ').strip
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
  # this is created only *once*
  def base_doc
    @base_doc ||= (
      doc = {
        :format_code_t => 'ead',
        :format_facet => 'Archival Documents',
        :filename_t => @base_filename,
        
        #:title_t => @xml.at('/ead/eadheader[1]/filedesc[1]/titlestmt[1]/titleproper[1]/text()').text,
        
        #:unittitle_t => (
        #  @xml.at('//archdesc[@level="collection"]/did/unittitle').text rescue
        #    @xml.at('//archdesc/did/unittitle').text rescue
        #      'Untitled'
        #),
        
        :institution_t => @xml.at('//publicationstmt/publisher/text()[1]').text.gsub(/\s+/," ").strip,
        :institution_facet => @xml.at('//repository//corpname').children.first.text.gsub(/\s+/," ").strip,
        :language_facet => self.languages,
        :rights_facet => self.rights_facet, 
        :rights_t => self.rights_text,
        :hierarchy_scope => self.collection_id,
        :collection_id => self.collection_id,
        :collection_facet => "Northwest Digital Archives EAD Guides",
        :availability_facet => "Not online. Must visit contributing institution.",
        :abstract_t => (@xml.at('//archdesc/did/abstract').text rescue nil),
        :text => []
        
      }
      
      # write values to :text to make them searchable
      # NOTE: isn't this already happening via copyField in the solr schema?
      doc[:text] << doc[:title_t] << doc[:institution_t] << doc[:collection_facet]
      
      # clean all values...
      doc.each_pair do |k,v|
        doc[k] = to_one_line(v)
      end
      doc
    )
  end
  
  # get all of the languages used in the EAD guide, not only the language in which the guide itself is encoded
  # normalize the language values, and only keep the unique ones
  def languages
    @xml.xpath('//language').map do |lang|
      lang.text.to_s.gsub(/\.|\,/,'').strip.capitalize.gsub("Finding aid written in english", "English")
    end.uniq
  end
  
  # interpret the text from //userestrict and turn it into a facet value
  def rights_facet
    raw = @xml.at('//userestrict[1]').to_s
    open('/tmp/output', 'a') { |f| f << "!! #{raw}\n" }    
    if raw=~/[Pp]ublic [Dd]omain/ 
      return "Public Domain"
    elsif raw=~/[Pp]ublic [Rr]ecord/ 
      return "Public Records"
    elsif raw=~/Creator retains literary rights/
      return "Creator retains literary rights."
    else
      return "Other"
    end
  end
  
  # record the information in the userestrict field 
  def rights_text
    raw = @xml.xpath('//userestrict[1]/p/text()').first.to_s.gsub(/\s+/," ").strip
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
      :title_t => label,
      :hierarchy => label
    })
  end
  
  # creates a /ead/archdesc based doc
  def create_desc_item(node_name, id_suffix)
    
    #puts "node_name = #{node_name}"
    #puts "id_suffix = #{id_suffix}"
    
    node = @xml.at('/ead/archdesc/' + node_name)
    return unless node
    
    if head = node.at('head')
      label = head.text.empty? ? id_suffix : head.text.capitalize
    else
      label = id_suffix
    end
    
    self.base_doc.merge({
      :xml_display => node.to_xml,
      :id => generate_id(id_suffix),
      :title_t => label,
      :hierarchy => label
    })
  end
  
  # creates an array of ead/archdesc/dsc/c docs
  def create_item_docs
    i=0
    @xml.search('ead/archdesc/dsc/c01[@level="series"]').inject([]) do |docs,c01|
      #puts "mapping c01 ##{i}"
      label = c01.at('did/unittitle').text.capitalize rescue "Unknown-#{i}"
      
      # remove leading/trailing : values (messes up the hierarchy calculations)
      label = label.gsub(/^\:+|\:+$/, '')
      
      rel_id = to_one_line(c01.at('did/unitid').text) rescue "Unknown ID-#{i}"
      i += 1
      id = generate_id(rel_id)
      docs << self.base_doc.merge({
        :id => id,
        :xml_display => c01.to_xml,
        :title_t => label,
        :hierarchy => "Collection Inventory::#{label}"
      })
      
      c01.css('c02').each_with_index do |cnode,ii|
        
        llabel = cnode.at('did/unittitle').text rescue nil
        llabel = "Unknown-#{i}-#{ii}" if llabel.blank?
        # remove line endings, tabs and trailing spaces
        llabel = llabel.gsub(/^\:+|\:+$/, '')
        
        format = c01.at('did/unittitle').text rescue 'Unknown'
        docs << self.base_doc.merge({
          :id => "#{id}-#{ii}",
          :xml_display => cnode.to_xml,
          :title_t => llabel,
          # make sure that the : separator occurs no more than twice in a row
          # "::" is the hierarchy separator...
          :hierarchy => "Collection Inventory::#{label}::#{llabel}".gsub(/:{3,}/, '::'),
          :part_of => [id],
          :format_code_t => format.downcase.gsub(' ', '_').gsub(/\W+/, '')
          #:format_facet => format.capitalize
        })
      end
      docs
    end
  end
  
end