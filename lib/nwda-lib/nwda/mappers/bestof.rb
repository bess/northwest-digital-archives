require 'rubygems'
require 'xml/xslt'
require 'find'
require 'rsolr'
require 'nokogiri'


class NWDA::Mappers::BestOf
  
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
      self.getPublisherFacet
      self.getLanguageFacet
      self.getRights
      self.getDescription
      self.isPartOf
      
      
      #self.storeRecord
      @doc[:collection_facet] = "University of Oregon Photograph Collection"
      @doc[:institution_facet] = "University of Oregon"
      @doc[:availability_facet] = "Available online"
      @doc
    end
    
    def isPartOf
      @doc[:isPartOfText_t] = @xml.xpath('./isPartOf[2]/text()').to_s.gsub(/\s+/," ").strip
      @doc[:isPartOfAddress_t] = @xml.xpath('./isPartOf[4]/text()').to_s.strip
    end
    
    def getDescription
      @doc[:description_t] = @xml.xpath('./description/text()').first.to_s.gsub(/\s+/," ").gsub("&lt;br&gt;","<br>")
      @doc[:text] << @doc[:description_t]
    end
    
    def getRights
      @doc[:rights_t] = @xml.xpath('./rights/text()').first.to_s.gsub(/\s+/," ").strip
      @doc[:rights_facet] = rights_facet(@doc[:rights_t])
    end
    
    def rights_facet(raw)
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
    
    def getImages
      thumbnail_url = @xml.xpath('./thumbnailURL[1]/text()').first.to_s
      @doc[:preview_display] = thumbnail_url
      img_id = thumbnail_url[/CISOPTR=\d+/]
      #puts "img_id = #{img_id}"
      @doc[:fullimage_display] = "http://boundless.uoregon.edu/cgi-bin/getimage.exe?CISOROOT=/Bestof&#{img_id}&DMWIDTH=1200&DMHEIGHT=1200&DMX=0&DMY=0&DMTEXT=&REC=1&DMTHUMB=0&DMROTATE=0"
    end
    
      # Store the whole record so we can display the parts we want at display time
      def storeRecord
        @doc[:herbarium_display] = @xml.to_xml
      end

      def getFormatFacet
        @doc[:format_facet] = "Photograph"
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
           t = @xml.xpath('./title[1]/text()').first.to_s.gsub(/\s+/," ").strip
           if t.length == 0
             t = "Untitled"
           end
           @doc[:title_t] = t
           
           @doc[:text] << @doc[:title_t].to_s
      end

      def getSubjects
            general_subjects = []
            @xml.xpath('./subject/text()').each_with_index do |subject, i|
              general_subjects.concat(subject.to_s.gsub("&amp;"," and ").gsub(/\s+/," ").gsub(/-+/,"-").gsub(/-/," -- ").split(';'))
            end
      
            @doc[:subject_facet] = general_subjects.uniq.map {|a| a.strip}
            @doc[:text] << @doc[:subject_facet].flatten
      end

      def getLanguageFacet
        @doc[:language_facet] = "English"
      end

      def getPublisherFacet
        @doc[:publisher_facet] = @xml.xpath('./publisher[1]/text()').first.to_s.gsub(/\s+/," ").strip
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