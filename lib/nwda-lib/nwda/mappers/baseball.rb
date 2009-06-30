require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'
require 'open-uri'


class NWDA::Mappers::Baseball
  
  attr_reader :doc, :xml

    #kick off mapping method
    def initialize(record)
      @xml = record
      @doc = {}
      @doc[:id] = self.getID
      @doc[:collection_id] = @doc[:id]
      @doc[:text] = []
      self.getFormatFacet
      self.getTitle
      self.getDescription
      # 
      @doc[:collection_facet] = "Oregon State Baseball"
      @doc[:institution_facet] = "Oregon State University"
      #       
      self.getImages
      self.getSubjects
      self.getDates
      self.getPublisherFacet
      self.getLanguageFacet
      self.getSource
      self.getRights
      self.getContributors
      
      @doc
    end
    
    def getContributors
      @doc[:contributor_t] = @xml.xpath('./contributor/text()').first.to_s
    end
    
    def getRights
      @doc[:rights_t] = @xml.xpath('./rights/text()').first.to_s
      @doc[:text] << @doc[:rights_t]
    end
    
    def getSource
      @doc[:source_t] = @xml.xpath('./source/text()').first.to_s
      @doc[:text] << @doc[:source_t]
    end
    
    # index the dates
    # store the first bit (e.g., "Ca. 1909") for display
    # If there is no ca. values, store the first year in the list
    # put the rest into categories like "over fifty years ago" etc.  
    def getDates
      date_string = @xml.xpath('./date/text()').first.to_s
      # Store the year as a string, along with the Ca., if it exists, so we can display it 
      @doc[:date_display] = date_string
            
      unless @doc[:date_display].nil?
        
        stripped_year = @doc[:date_display][/\d{4}/]
        
        unless stripped_year.nil?
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
      
      
      
    end
    
    
    def getImages
      thumbnail_url = @xml.xpath('./thumbnailURL[1]/text()').first.to_s
      @doc[:preview_display] = thumbnail_url
      img_id = thumbnail_url[/CISOPTR=\d+/]
      @doc[:fullimage_display] = "http://digitalcollections.library.oregonstate.edu/cgi-bin/getimage.exe?CISOROOT=/baseball&#{img_id}&DMSCALE=25.00000&DMWIDTH=1200&DMHEIGHT=1200&DMX=0&DMY=0&DMTEXT=&REC=1&DMTHUMB=0&DMROTATE=0"
    end
    
      # Store the whole record so we can display the parts we want at display time
      def storeRecord
        @doc[:xml_display] = @xml.to_xml
      end

      def getFormatFacet
        formats = []
        @xml.xpath('./format/text()').each_with_index do |format, i|
          formats.concat(format.to_s.gsub("&amp;"," and ").gsub(/\s+/," ").gsub(/-+/,"-").gsub(/-/," -- ").split(';'))
        end
  
        @doc[:format_facet] = formats.uniq.map {|a| a.strip}
        @doc[:text] << @doc[:format_facet].flatten
      end

      def getID
        identifier = @xml.xpath('./viewerURL/text()').first.to_s
        last_bit = identifier[/\w+,\d+$/].tr(',','_')
        return last_bit
      end

      def getTitle
        @doc[:title_t] = @xml.xpath('./title/text()').first
        @doc[:text] << @doc[:title_t].to_s
      end
      
      def getDescription
        @doc[:description_t] = @xml.xpath('./description/text()').first.to_s.gsub(/\s+/," ").gsub("&lt;br&gt;","<br>")
        @doc[:text] << @doc[:description_t]
      end
      
      def getSubjects
            general_subjects = []
            @xml.xpath('./subject/text()').each_with_index do |subject, i|
              general_subjects.concat(subject.to_s.gsub("&amp;"," and ").gsub(/\s+/," ").gsub(/-+/,"-").gsub(/-/," -- ").split(';'))
            end
      
            @doc[:subject_facet] = general_subjects.uniq.map {|a| a.strip}
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
         @doc[:publisher_facet] = @xml.xpath('./publisher/text()').first
         @doc[:text] << @doc[:publisher_facet].to_s
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