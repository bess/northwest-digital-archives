#require 'marc'

module Blacklight::Solr::Doc::Ext::EAD
  
  #autoload :Citation, 'blacklight/solr/doc/ext/ead/citation'
  
  def storage
    @ead_document ||= Document.new(self)
  end
  
  class Document
    
    # include Citation
    #    
       #attr_reader :table, :marc
       
       def initialize(hash)
         #@ead = 
       end
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
  
end