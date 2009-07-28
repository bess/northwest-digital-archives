require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'


class NWDA::Mappers::JASR
  
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
      self.getAuthor
      self.getDates
      #self.getImages
      # 
      self.getSubjects
      # self.getGeographicSubjects
      self.getPublisherFacet
      self.getLanguageFacet
      self.getRights
      
      #self.storeRecord
      @doc[:collection_facet] = "National Japanese American Student Relocation Council Records"
      @doc[:institution_facet] = "University of Oregon"
      @doc[:availability_facet] = "Available online"
      @doc
    end
    
    # index the dates
    # store the first bit (e.g., "Ca. 1909") for display
    # If there is no ca. values, store the first year in the list
    # put the rest into categories like "over fifty years ago" etc.  
    def getDates
      date_string = @xml.xpath('./temporal/text()').first.to_s
      
      # Store the year as a string, along with the Ca., if it exists, so we can display it 
      @doc[:date_display] = date_string
      
      date = @xml.xpath('./date/text()').first.to_s
      
      if date
        
        stripped_year = date[/\d{4}/]
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
    
    
    def getRights
      @doc[:rights_t] = @xml.xpath('./rights/text()').first.to_s
      @doc[:rights_facet] = "Creative Commons Licensed"
    end
    
    def getImages
      thumbnail_url = @xml.xpath('./thumbnailURL[1]/text()').first.to_s
      @doc[:preview_display] = thumbnail_url
      img_id = thumbnail_url[/CISOPTR=\d+/]
      #puts "img_id = #{img_id}"
      @doc[:fullimage_display] = "http://digitalcollections.library.oregonstate.edu/cgi-bin/getimage.exe?CISOROOT=/herbarium&#{img_id}&DMSCALE=25.00000&DMWIDTH=1200&DMHEIGHT=1200&DMX=0&DMY=0&DMTEXT=&REC=1&DMTHUMB=0&DMROTATE=0"
    end
    
      # Store the whole record so we can display the parts we want at display time
      def storeRecord
        @doc[:herbarium_display] = @xml.to_xml
      end

      def getFormatFacet
        @doc[:format_facet] = "Archival Document"
      end

      def getID
          id = @xml.xpath('./identifier/text()').first
          puts id
          id
      end

      def getTitle
           t = @xml.xpath('./title[1]/text()').first.to_s
           @doc[:title_t] = t
           @doc[:text] << @doc[:title_t].to_s
      end
      
      def getAuthor
            all_authors = []
            @xml.xpath('./creator/text()').each_with_index do |creator, i|
              all_authors.concat(creator.to_s.gsub("&amp;"," and ").gsub(/\s+/," ").split(';'))
            end
            @doc[:author_t] = all_authors.uniq
            @doc[:text] << @doc[:author_t].flatten
       end

      def getSubjects
            general_subjects = []
            @xml.xpath('./subject/text()').each_with_index do |subject, i|
              general_subjects.concat(subject.to_s.gsub("&amp;"," and ").gsub(/\s+/," ").gsub(/-+/,"-").gsub(/-/," -- ").split(';'))
            end
            @doc[:subject_facet] = general_subjects.uniq
            @doc[:text] << @doc[:subject_facet].flatten
       end

      def getGeographicSubjects
        geographic_subject_facet = []
        @xml.xpath('./spatial/text()').each_with_index do |subject, i|
          geographic_subject_facet[i] = subject.content.gsub(/\s+/," ")
        end
        @doc[:geographic_subject_facet] = geographic_subject_facet.uniq
      end

      def getLanguageFacet
        @doc[:language_facet] = "English"
      end

      def getPublisherFacet
        @doc[:publisher_facet] = "University of Oregon Libraries"
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