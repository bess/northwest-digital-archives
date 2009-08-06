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
  
  def title
    #@title ||= @xml.at('/ead/eadheader[1]/filedesc[1]/titlestmt[1]/titleproper[1]/text()').text
    @title ||= (@xml.xpath('//archdesc[@level="collection"]/did/unittitle').first.text rescue
      @xml.xpath('//archdesc/did/unittitle').first.text rescue
        'Untitled')
  end
  
  # removes newlines, tabs, multiple spaces and beginning/trailing spaces.
  # if the argument is an Array, each item in the array is processed recursively.
  def to_one_line(v)
    if v.is_a?(Array)
      v.each_with_index do |vv,i|
        v[i] = to_one_line(vv)
      end
      v
    else
      v.to_s.gsub(/\n+|\t+/, '').gsub(/ +/, ' ').strip
    end
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
    solr_docs.compact!
    solr_docs.collect do |doc|
      # clean all values...
      doc.each_pair do |k,v|
        doc[k] = to_one_line(v)
        if k == :hierarchy
          # elminate sequences of >= 3 :
          doc[k] = v.join('::').gsub(/:{3,}/, '::')
        end
      end
    end
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
        :format_facet => 'Archival Collection Guide',
        :filename_t => @base_filename,
        
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
        :collapse_collection_id => self.collection_id,
        :collection_id => self.collection_id,
        :collection_facet => "Northwest Digital Archives EAD Guides",
        :availability_facet => "Not online. Must visit contributing institution.",
        :abstract_t => (@xml.at('//archdesc/did/abstract').text rescue nil),
        :text => []
        
      }
      
      # write values to :text to make them searchable
      # NOTE: isn't this already happening via copyField in the solr schema?
      doc[:text] << doc[:title_t] << doc[:institution_t] << doc[:collection_facet]
      
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
    doc = self.base_doc.merge({
      :xml_display => @xml.at("/ead/archdesc/did").to_xml,
      :id => generate_id('summary'),
      :title_t => label,
      :hierarchy => [self.title, label]
    })
    doc
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
    
    doc = self.base_doc.merge({
      :xml_display => node.to_xml,
      :id => generate_id(id_suffix),
      :title_t => label,
      :hierarchy => [self.title, label]
    })
    doc
  end
  
  def create_item_docs
    docs = []
    @xml.xpath('ead/archdesc/dsc/c01[@level="series"]').each_with_index do |c01,i|
      # remove leading/trailing : values (messes up the hierarchy calculations)
      label = c01.at('did/unittitle').text.capitalize.gsub(/^\:+|\:+$/, '') rescue "Unknown-#{i}"
      rel_id = to_one_line(c01.at('did/unitid').text) rescue "Unknown ID-#{i}"
      id = generate_id(rel_id)
      docs << self.base_doc.merge({
        :id => id,
        :xml_display => c01.to_xml,
        :title_t => label,
        :hierarchy => [self.title, "Collection Inventory", label]
      })
      
      item_format = c01.at('did/unittitle').text.downcase.gsub(' ', '_').gsub(/\W+/, '') rescue 'Unknown'
      # loop through all c03 items
      c01.xpath('.//c03[@level="item"]').each_with_index do |c03,ii|
        
        # remove line endings, tabs and trailing spaces
        llabel = c03.at('did/unittitle').text.gsub(/^\:+|\:+$/, '') rescue "Unknown-#{i}-#{ii}"
        docs << self.base_doc.merge({
          :id => "#{id}-#{ii}",
          :xml_display => c03.to_xml,
          :title_t => llabel,
          # make sure that the : separator occurs no more than twice in a row
          # "::" is the hierarchy separator...
          :format_code_t => item_format,
          :hierarchy => [self.title, "Collection Inventory", label, llabel],
          :format_facet => "Archival Document",
          :collapse_collection_id => "#{id}-#{ii}"
        })
        
        image_data = c03.xpath('.//did/daogrp/daoloc').first
        
        if image_data and image_data['href']
          #puts "FOUND IMAGE DATA..."
          path, num = image_data['href'].split('?').last.split(',')
          base = "https://content-dev.lib.washington.edu/cgi-bin/getimage.exe"
          docs.last[:preview_display] = "#{base}?CISOROOT=#{path}&CISOPTR=#{num}&DMSCALE=25.00000"
          docs.last[:fullimage_display] = "#{base}?CISOROOT=#{path}&CISOPTR=#{num}&DMSCALE=100.00000"
          #puts docs.last.inspect
        end
        
        #puts docs.last.inspect
        
      end
    end
    docs
  end
  
end