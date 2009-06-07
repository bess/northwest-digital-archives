require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'
require 'open-uri'


class NWDA::Mappers::Pullman
  
  attr_reader :doc, :xml

    #kick off mapping method
    def initialize(record)
      @xml = record
      @doc = {}
      @doc[:id] = self.getID
      self.getFormatFacet
      self.getTitle
      self.getDescription

      @doc[:collection_facet] = "City of Pullman Collection"
      
      self.getImages
      self.getSubjects
      self.getDates
      self.getPublisherFacet
      self.getLanguageFacet
      @doc
    end
    
    # index the dates
    # store the first bit (e.g., "Ca. 1909") for display
    # If there is no ca. values, store the first year in the list
    # put the rest into categories like "over fifty years ago" etc.  
    def getDates
      date_string = @xml.xpath('./dc:date/text()').first.to_s
      
      # Store the year as a string, along with the Ca., if it exists, so we can display it 
      @doc[:date_display] = date_string[/^[Cc]a\.+ *\d+|^\d+/]
      
      if @doc[:date_display]
        stripped_year = @doc[:date_display].gsub(/^[Cc]a\.+ */,'')
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
        @doc[:format_facet] = []
        @doc[:genre_facet] = []
        
        formats = @xml.xpath('./dc:type/text()').first.to_s.split("&lt;br&gt;")
        
        formats.each do |f|
          # record the genre as-is
          @doc[:genre_facet] << f.strip.capitalize
          
          # but provide some normalization for the format facet
          if(f =~ /(P|p)hoto/)
            @doc[:format_facet] << "Photograph"
          else
            @doc[:format_facet] << f.strip.capitalize
          end
        end 
      end

      def getID
        about = @xml.xpath('@about').text
        last_bit = about.split('http://kaga.wsulibs.wsu.edu/u?/')[1].tr(',','_')
      end

      def getTitle
        @doc[:title_t] = @xml.xpath('./dc:title/text()').first
      end
      
      def getDescription
        @doc[:description_t] = @xml.xpath('./dc:description/text()').first.to_s.gsub(/\s+/," ")
      end
      
      def getUniqueValuesBR(xpath)
        
      end
      
      
      def getSubjects
            general_subjects = []
            @xml.xpath('./dc:subject/text()').each_with_index do |subject, i|
              general_subjects.concat(subject.to_s.gsub("&amp;"," and ").gsub(/\s+/," ").gsub(/-+/,"-").gsub(/-/," -- ").split(';'))
            end
      
            @doc[:subject_facet] = general_subjects.uniq
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