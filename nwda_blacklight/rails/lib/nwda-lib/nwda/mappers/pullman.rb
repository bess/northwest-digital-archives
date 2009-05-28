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
      # self.getSubjects
      # self.getGeographicSubjects
      # self.getPublisherFacet
      # self.getLanguageFacet
      # self.storeRecord
      @doc
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
        puts "about = #{about}"
        last_bit = about.split('http://kaga.wsulibs.wsu.edu/u?/')[1].tr(',','_')
      end

      def getTitle
        @doc[:title_t] = @xml.xpath('./dc:title/text()').first
      end
      
      def getDescription
        @doc[:description_t] = @xml.xpath('./dc:description/text()').first
      end
      
      def getUniqueValuesBR(xpath)
        
      end
      
      # 
      # def getSubjects
      #       general_subjects = []
      #       @xml.xpath('./subject/text()').each_with_index do |subject, i|
      #         general_subjects[i] = subject.content.gsub(/\s+/," ")
      #       end
      # 
      #       @doc[:subject_facet] = general_subjects.uniq
      #  end
      # 
      # def getGeographicSubjects
      #   geographic_subject_facet = []
      #   @xml.xpath('./spatial/text()').each_with_index do |subject, i|
      #     geographic_subject_facet[i] = subject.content.gsub(/\s+/," ")
      #   end
      #   @doc[:geographic_subject_facet] = geographic_subject_facet.uniq
      # end
      # 
      # def getLanguageFacet
      #   @doc[:language_facet] = "English"
      # end
      # 
      # def getPublisherFacet
      #   @doc[:publisher_facet] = "Oregon State University Herbarium"
      # end

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