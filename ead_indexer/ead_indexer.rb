require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'

solr = RSolr.connect(:url=>'http://alliancedev.uoregon.edu:8983/solr')

#solr.add(:id=>1, :title_t=>"mytitle")
#solr.commit


Find.find('../raw_data/hold/Alaska State Library--Historical Collections/') do |path| 
#Find.find('../raw_data/hold/') do |path| 

#path = "../raw_data/hold/Alaska State Library--Historical Collections/ALKMS010.xml"
  if File.file? path
    
    xml = Nokogiri::XML(open(path))
    doc = {}
    
    xml.xpath('/ead/eadheader/eadid/text()').each do |id|
      doc[:id] = id.content.strip.downcase
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

    doc[:subject_t] = name_subjects.uniq.concat(general_subjects.uniq)
    
    puts doc.inspect
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
