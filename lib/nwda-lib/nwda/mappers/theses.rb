require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'
require 'open-uri'


class NWDA::Mappers::Theses
  
  attr_reader :doc, :xml

    #kick off mapping method
    def initialize(record)
      @xml = record
      @doc = {}
      @doc[:id] = self.getID
      @doc[:text] = []
      self.getFormatFacet
      self.getTitle
      self.getAuthor
      self.getDescription
      self.getURI

      @doc[:collection_facet] = "Washington State University Theses"
      
      # self.getImages
      self.getSubjects
      self.getDates
      # self.getPublisherFacet
      self.getLanguageFacet
      # self.getCoverage
      # self.getSource
      # self.getRights
      # self.getContributors
      @doc
    end
    
    def getContributors
      @doc[:contributor_t] = @xml.xpath('./dc:contributor/text()').first.to_s
    end
    
    def getRights
      @doc[:rights_t] = @xml.xpath('./dc:rights/text()').first.to_s
    end
    
    def getSource
      @doc[:source_t] = @xml.xpath('./dc:source/text()').first.to_s
      @doc[:text] << @doc[:source_t]
    end
    
    # Get the geographic coverage of this item
    # Store both the full string (all the bits appended)
    # and the broken up string, to more easily find different levels of geographic hierarchy 
    def getCoverage
      cov_string = @xml.xpath('./dc:coverage/text()').first.to_s.gsub(/\s+/," ").gsub(/-+/,"-").gsub(/-/," -- ")
      coverage = []
      coverage << cov_string
      coverage.concat(cov_string.split(' -- '))
      coverage2 = []
      coverage.each do |c|
        coverage2 << c.strip
      end
      @doc[:geographic_subject_facet] = coverage2.uniq
      @doc[:text] << @doc[:geographic_subject_facet].flatten
    end
    
    # index the dates
    # store the first bit (e.g., "Ca. 1909") for display
    # If there is no ca. values, store the first year in the list
    # put the rest into categories like "over fifty years ago" etc.  
    def getDates
      date_string = @xml.xpath('./metadata/oai_dc:dc/dc:date[3]/text()').first.to_s
      
      # Store the year as a string, along with the Ca., if it exists, so we can display it 
      @doc[:date_display] = date_string[/\d{4}/]
      
      if @doc[:date_display]
        
        stripped_year = @doc[:date_display][/\d{4}/]
        # Store the year as an actual date, so we can do math on it 
        @doc[:creation_date] = stripped_year.concat("-01-01T23:59:59Z")
        # Store a range value
        creation_era = []
        if 100.years.ago > DateTime.parse(stripped_year)
          creation_era << "More than 100 years old"
        end
        if 50.years.ago > DateTime.parse(stripped_year)
          creation_era << "More than 50 years old"
        end
        if 20.years.ago > DateTime.parse(stripped_year)
          creation_era << "More than 20 years old"
        end
        if 10.years.ago > DateTime.parse(stripped_year)
          creation_era << "More than 10 years old"
        end
        if 10.years.ago <= DateTime.parse(stripped_year)
          creation_era << "Less than 10 years old"
        end
        if 5.years.ago <= DateTime.parse(stripped_year)
          creation_era << "Less than 5 years old"
        end
        if 1.year.ago <= DateTime.parse(stripped_year)
          creation_era << "Less than 1 year old"
        end
        @doc[:subject_era_facet] = creation_era
      end
    end
    
    
    def getImages
      about = @xml.xpath('@about').text
      number = about.split(',')[1]
      @doc[:preview_display] = "http://kaga.wsulibs.wsu.edu/cgi-bin/thumbnail.exe?CISOROOT=/pullman&CISOPTR=#{number}"
      @doc[:fullimage_display] = "http://kaga.wsulibs.wsu.edu/cgi-bin/getimage.exe?CISOROOT=/pullman&CISOPTR=#{number}&DMSCALE=100.00000&DMWIDTH=1200&DMHEIGHT=1200&DMX=0&DMY=0&DMTEXT=&REC=1&DMTHUMB=0&DMROTATE=0"
    end
    
      # Store the whole record so we can display the parts we want at display time
      def storeRecord
        @doc[:xml_display] = @xml.to_xml
      end

      def getFormatFacet
        @doc[:format_facet] = @xml.xpath('./metadata/oai_dc:dc/dc:type/text()').first.to_s
        @doc[:text] << @doc[:format_facet]
      end

      def getID
        identifier = @xml.xpath('./header/identifier').text
        return "wsu_" + identifier[/\d+\/\d+$/].tr('/','_')
      end
      
      def getURI
        @doc[:uri_display] = @xml.xpath('./metadata/oai_dc:dc/dc:identifier/text()').first.to_s
        @doc[:text] << @doc[:uri_display]
      end

      def getTitle
        @doc[:title_t] = @xml.xpath('./metadata/oai_dc:dc/dc:title/text()').first.to_s.gsub(/\s+/," ")
        @doc[:text] << @doc[:title_t]
      end
      
      def getAuthor
        @doc[:author_t] = @xml.xpath('./metadata/oai_dc:dc/dc:creator/text()').first.to_s.gsub(/\s+/," ")
        @doc[:text] << @doc[:author_t]
      end
      
      # get all of the description nodes
      def getDescription
        d = []
        @xml.xpath('./metadata/oai_dc:dc/dc:description/text()').each do |node|
          d << node.to_s.gsub(/\s+/," ").gsub("&lt;br&gt;","<br>")
        end
        @doc[:description_t] = d
        @doc[:text] << @doc[:description_t]
      end
      
      def getUniqueValuesBR(xpath)
        
      end
      
      
      def getSubjects
            general_subjects = []
            @xml.xpath('./metadata/oai_dc:dc/dc:subject/text()').each_with_index do |subject, i|
              general_subjects.concat(subject.to_s.gsub("&amp;"," and ").gsub(/\s+/," ").gsub(/-+/,"-").gsub(/-/," -- ").split(';'))
            end
      
            @doc[:subject_facet] = general_subjects.uniq
            @doc[:text] << @doc[:subject_facet].flatten
       end
       

      
      
      # 
      # def getGeographicSubjects
      #   geographic_subject_facet = []
      #   @xml.xpath('./spatial/text()').each_with_index do |subject, i|
      #     geographic_subject_facet[i] = subject.content.gsub(/\s+/," ")
      #   end
      #   @doc[:geographic_subject_facet] = geographic_subject_facet.uniq
      # end
      # 
      def getLanguageFacet
         @doc[:language_facet] = "English"
      end
      # 
      def getPublisherFacet
         @doc[:publisher_facet] = "Washington State University Libraries"
      end

      # 
      # def getGenreFormatFacet
      #   genreform_facet = []
      #   @xml.xpath('//genreform/text()').each_with_index do |form, i|
      #     genreform_facet[i] = form.content.gsub(/\s+/," ").strip
      #   end
      #   @doc[:genreform_facet] = genreform_facet.uniq 
      # end

       def inspect
         puts @doc.inspect
       end
  
end