require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'


class NWDA::Mappers::Herbarium
  
  attr_reader :doc, :xml

    #pass in an EAD document
    #set @ead_document
    #kick off mapping method
    def initialize(record)
      @xml = record
      @doc = {}
      self.getID
      @doc[:collection_id] = @doc[:id]
      @doc[:text] = []
      self.getFormatFacet
      self.getTitle
      self.getImages
      
      self.getSubjects
      self.getGeographicSubjects
      self.getPublisherFacet
      self.getLanguageFacet
      self.getRights
      
      #self.storeRecord
      @doc[:collection_facet] = "Oregon State University Herbarium"
      @doc[:institution_facet] = "Oregon State University"
      @doc[:availability_facet] = "Available online"
      @doc
    end
    
    def getRights
      @doc[:rights_t] = @xml.xpath('./rights/text()').first.to_s
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
        @doc[:format_facet] = "Herbarium Specimen"
      end

      def getID
          potential_ids=[]
          @xml.xpath('./identifier/text()').each_with_index do |id,i| 
            potential_ids[i] = id.content.gsub(/\//,"_").strip.gsub(/\s+/,"_").downcase.gsub(/\.pdf/,'')
          end
          potential_ids = potential_ids.uniq
          @doc[:id] = potential_ids[0]
      end

      def getTitle
           t = @xml.xpath('./title[1]/text()').first.to_s
           @doc[:title_t] = t
           @doc[:original_identification_display] = @xml.xpath('./alternative[1]/text()').first
           @doc[:family_display] = @xml.xpath('./subject[1]/text()').first
           @doc[:current_taxon_display] = @xml.xpath('./alternative[2]/text()').first
           @doc[:primary_collector_display] = @xml.xpath('./creator[2]/text()').first
           @doc[:collection_date_display] = @xml.xpath('./date[1]/text()').first
           
           @doc[:text] << @doc[:title_t].to_s
           @doc[:text] << @doc[:original_identification_display]
           @doc[:text] << @doc[:family_display]
           @doc[:text] << @doc[:primary_collector_display]
      end

      def getSubjects
            general_subjects = []
            @xml.xpath('./subject/text()').each_with_index do |subject, i|
              general_subjects[i] = subject.content.gsub(/\s+/," ")
            end

            @doc[:subject_facet] = general_subjects.uniq
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
        @doc[:publisher_facet] = "Oregon State University Herbarium"
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