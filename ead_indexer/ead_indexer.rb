require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'

#solr = RSolr.connect(:url=>'http://alliancedev.uoregon.edu:8983/solr')
solr = RSolr.connect(:url=>'http://127.0.0.1:8983/solr')


#solr.add(:id=>1, :title_t=>"mytitle")
#solr.commit


#Find.find('../raw_data/hold/Washington State University Libraries, Manuscripts, Archives, and Special Collections/') do |path| 
#Find.find('../raw_data/hold/Eastern Washington University/') do |path| 
  
Find.find('../raw_data/hold/') do |path| 

#path = "../raw_data/hold/Alaska State Library--Historical Collections/ALKMS010.xml"
  if File.directory? path
    puts "Indexing #{path}"
  end
  if File.file? path
    #puts "Indexing file #{path}"
    
    xml = Nokogiri::XML(open(path))
    doc = {}
    
    #xml.xpath('/ead/eadheader/eadid/text()').each do |id|
    xml.xpath('/ead/eadheader/eadid/@identifier').each do |id| 
      doc[:id] = id.content.gsub(/\//,"_").strip.gsub(/\s+/,"_").downcase
    end
    
    xml.xpath('/ead/eadheader/filedesc/titlestmt/titleproper[1]/text()').each do |title|
      doc[:title_t] = title.content.gsub(/\s+/," ")
    end
    
    general_subjects = []
    xml.xpath('//subject/text()').each_with_index do |subject, i|
      general_subjects[i] = subject.content.gsub(/\s+/," ")
    end
    
    name_subjects = []
    xml.xpath('//persname|famname|corpname[@role="subject"]/text()').each_with_index do |subject, i|
      name_subjects[i] = subject.content.gsub(/\s+/," ")
    end

    doc[:subject_facet] = name_subjects.uniq.concat(general_subjects.uniq)
    
    geographic_subject_facet = []
    xml.xpath('//geogname/text()').each_with_index do |subject, i|
      geographic_subject_facet[i] = subject.content.gsub(/\s+/," ")
    end
    doc[:geographic_subject_facet] = geographic_subject_facet
    
    language_facet = []
    xml.xpath('//language/text()').each_with_index do |language, i|
      language_facet[i] = language.content.gsub(/\s+/," ").strip
    end
    doc[:language_facet] = language_facet.uniq
    
    publisher_facet = []
    xml.xpath('/ead/eadheader/filedesc/publicationstmt/publisher/text()').each_with_index do |publisher, i|
      publisher_facet[i] = publisher.content.gsub(/\s+/," ").strip
    end
    doc[:publisher_facet] = publisher_facet.uniq
    
    
    
    genreform_facet = []
    xml.xpath('//genreform/text()').each_with_index do |form, i|
      genreform_facet[i] = form.content.gsub(/\s+/," ").strip
    end
    doc[:genreform_facet] = genreform_facet.uniq
    
    doc[:format_facet] = "EAD"
    
    #puts doc.inspect
    solr.add(doc)
  end
end 
solr.commit

def set_subjects
  
end



# 
# xslt = XML::XSLT.new() 
# xslt.xml = "../raw_data/hold/Alaska State Library--Historical Collections/ALKMS010.xml"
# xslt.xsl = "xsl/ead_to_solr.xsl"
# 
# out = xslt.serve()
# print out;
