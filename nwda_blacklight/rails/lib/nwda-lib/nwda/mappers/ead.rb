require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'

class NWDA::Mappers::EAD
  
  attr_reader :doc, :xml
  
  #pass in an EAD document
  #set @ead_document
  #kick off mapping method
  def initialize(ead_file)
    @xml = Nokogiri::XML(open(ead_file))
    @doc = {}
    self.getID
    self.getFormatFacet
    self.getTitle
    self.getSubjects
    self.getGeographicSubjects
    self.getPublisherFacet
    self.getGenreFormatFacet
    self.getLanguageFacet
    self.getAbstract
    self.getBiogHist
    self.getEAD
  end
  
  def getFormatFacet
    @doc[:format_facet] = "EAD"
  end
  
  def getID
    @xml.xpath('/ead/eadheader/eadid/@identifier').each do |id| 
      @doc[:id] = id.content.gsub(/\//,"_").strip.gsub(/\s+/,"_").downcase
    end
  end

  def getTitle
    titles = []
    @xml.xpath('/ead/eadheader/filedesc/titlestmt/titleproper[1]/text()').each_with_index do |title,i|
      titles[i] = title.content.gsub(/\s+/," ")
    end
    @doc[:title_t] = titles.uniq
  end
  
  def getSubjects
    general_subjects = []
    @xml.xpath('//subject/text()').each_with_index do |subject, i|
      general_subjects[i] = subject.content.gsub(/\s+/," ")
    end
    
    name_subjects = []
    @xml.xpath('//persname|famname|corpname[@role="subject"]/text()').each_with_index do |subject, i|
      name_subjects[i] = subject.content.gsub(/\s+/," ")
    end

    @doc[:subject_facet] = name_subjects.uniq.concat(general_subjects.uniq)
  end
  
  def getGeographicSubjects
    geographic_subject_facet = []
    @xml.xpath('//geogname/text()').each_with_index do |subject, i|
      geographic_subject_facet[i] = subject.content.gsub(/\s+/," ")
    end
    @doc[:geographic_subject_facet] = geographic_subject_facet.uniq
  end
  
  def getLanguageFacet
    language_facet = []
    @xml.xpath('//language/text()').each_with_index do |language, i|
      language_facet[i] = language.content.gsub(/\s+/," ").strip
    end
    @doc[:language_facet] = language_facet.uniq
  end
  
  def getPublisherFacet
    publisher_facet = []
    @xml.xpath('/ead/eadheader/filedesc/publicationstmt/publisher/text()').each_with_index do |publisher, i|
      publisher_facet[i] = publisher.content.gsub(/\s+/," ").strip
    end
    @doc[:publisher_facet] = publisher_facet.uniq
  end
  
  def getGenreFormatFacet
    genreform_facet = []
    @xml.xpath('//genreform/text()').each_with_index do |form, i|
      genreform_facet[i] = form.content.gsub(/\s+/," ").strip
    end
    @doc[:genreform_facet] = genreform_facet.uniq 
  end
  
  def getAbstract
    @doc[:abstract_t] = @xml.xpath('//abstract/text()').to_xml 
   #puts @xml.xpath('//abstract/text()').to_xml.gsub(/\s+/," ")
  end
  
  def getBiogHist
    @doc[:biography_t] = @xml.xpath('//bioghist').to_xml
  end
  
  def getEAD
    @doc[:ead_display] = @xml.to_xml
  end
  
  def inspect
    puts @doc.inspect
  end
  
end