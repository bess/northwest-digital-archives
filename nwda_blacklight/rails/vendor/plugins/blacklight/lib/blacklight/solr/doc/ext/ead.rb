require 'marc'

module Blacklight::Solr::Doc::Ext::EAD
  
  autoload :Citation, 'blacklight/solr/doc/ext/ead/citation'
  
  def storage
    # @marc_document ||= Document.new(self)
  end
  
  class Document
    
    # include Citation
    #    
    #    attr_reader :table, :marc
    #    
    #    def initialize(hash)
    #      marc_field = Blacklight.config[:raw_storage_field]
    #      marc_type = Blacklight.config[:raw_storage_type]
    #      marc_data = hash.fetch marc_field
    #      case marc_type
    #        when 'marcxml'
    #          reader = MARC::XMLReader.new(StringIO.new(marc_data)).to_a
    #          @marc = reader[0]
    #        when 'marc21'
    #          @marc = MARC::Record.new_from_marc(marc_data)
    #        else
    #        # Some Default Object created from data? raise exception?
    #      end
    #    end
    #    
    #    def marc_xml
    #      return nil if marc.blank?
    #      marc.to_xml.to_s
    #    end
    #    
    #    def to_xml
    #      if marc 
    #        self.marc_xml
    #      else
    #        "<not-implemented/>"
    #      end
    #    end
    #    
    #  end
  
end