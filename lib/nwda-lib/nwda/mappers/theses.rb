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
        @doc[:collection_id] = @doc[:id]
        @doc[:text] = []
        self.getFormatFacet
        self.getTitle
        self.getAuthor
        self.getDescription
        self.getURI

        @doc[:collection_facet] = "Washington State University Theses"
        @doc[:collapse_collection_id] = @doc[:id]
        @doc[:institution_facet] = "Washington State University"
        @doc[:availability_facet] = "Available online"
      
        #self.getPDF
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
      
      # ##################
      def getURI
        @doc[:uri_display] = @xml.xpath('./metadata/oai_dc:dc/dc:identifier/text()').first.to_s
        #puts "uri = #{@doc[:uri_display]}"
        @doc[:text] << @doc[:uri_display]
      end
      
      # ##################
      def getPDF
        # fetch the remote document
        id = @doc[:uri_display][/\d+\/\d+$/]
        unless id.nil?
          conn = Net::HTTP.new('research.wsulibs.wsu.edu','8443')
          conn.use_ssl = true
          conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
          uri = "/dspace/handle/" + id.to_s
          d = conn.get uri
          #puts doc.class
          doc = Nokogiri::HTML(d.body)
          l = doc.css('a').map { |link| link['href'] }
          puts l.class
          puts l.grep /[pdf]/
          #puts doc.body
        #puts doc.css("a").find_all { |x| x['href'] =~ /\.pdf/ }
        #puts uri
        end
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

      def getTitle
        @doc[:title_t] = @xml.xpath('./metadata/oai_dc:dc/dc:title/text()').first.to_s.gsub(/\s+/," ")
        @doc[:text] << @doc[:title_t]
      end
      
      # ##################
      def getAuthor
        @doc[:author_t] = @xml.xpath('./metadata/oai_dc:dc/dc:creator/text()').first.to_s.gsub(/\s+/," ")
        @doc[:byline_t] = @doc[:author_t]
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
      
      # ##################
      def getSubjects
            general_subjects = []
            @xml.xpath('./metadata/oai_dc:dc/dc:subject/text()').each_with_index do |subject, i|
              general_subjects.concat(subject.to_s.gsub("&amp;"," and ").gsub(/\s+/," ").gsub(/-+/,"-").gsub(/-/," -- ").split(';'))
            end
      
            @doc[:subject_facet] = general_subjects.uniq
            @doc[:text] << @doc[:subject_facet].flatten
       end
       
      # ################## 
      def getLanguageFacet
         @doc[:language_facet] = "English"
      end
      
      # ##################
      def getPublisherFacet
         @doc[:publisher_facet] = "Washington State University Libraries"
      end
      
      # ##################
     def inspect
       puts @doc.inspect
     end
  
end