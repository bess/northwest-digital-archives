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
      self.getFormatFacet
      self.getTitle
      self.getSubjects
      self.getGeographicSubjects
      self.getPublisherFacet
      #     self.getGenreFormatFacet
      self.getLanguageFacet
      @doc
    end

      def getFormatFacet
        @doc[:format_facet] = "Herbarium Specimen"
      end

      def getID
          @xml.xpath('./identifier[1]/text()').each do |id| 
            @doc[:id] = id.content.gsub(/\//,"_").strip.gsub(/\s+/,"_").downcase unless id.to_s.strip=~/^.*\.[tif|pdf]$/
          end
      end

      def getTitle
        titles = []
        @xml.xpath('./title/text()').each_with_index do |title,i|
          titles[i] = title.content.gsub(/\s+/," ")
        end
        @doc[:title_t] = titles.uniq
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