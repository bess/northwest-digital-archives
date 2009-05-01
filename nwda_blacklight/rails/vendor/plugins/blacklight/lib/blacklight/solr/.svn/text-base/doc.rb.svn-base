#
# Solr::Doc is a module meant to be mixed in (#include) to your solr document class.
# Example (in models/solr_document.rb etc.)
#
# class SolrDoc
#   include Blacklight::Solr::Doc
# end
#
# It acts as a raw solr document hash wrapper: SolrDoc.new({}) --
# ...so whatever is passed in is what gets wrapped (by using Ruby's #method_missing)
#
# It also provides an after_initialize class level method which can provide a convenient
# point for modifying each instance.
#
# Example:
# 
# class SolrDoc
#
#   include Blacklight::Solr::Doc
#   include UVA::SolrDoc::Common # module containing helper methods: (fedora?, marc?)
# 
#   after_initialize do
#     # scope here is an object instance, so we use #extend:
#     extend UVA::Marc if marc?
#     extend UVA::Fedora if fedora?
#   end
# 
# end
module Blacklight::Solr::Doc
  
  autoload :Ext, 'blacklight/solr/doc/ext.rb'
  
  # Class level methods for altering object instances
  module Callbacks
    
    # creates the @hooks container ("hooks" are blocks or procs).
    # returns an array
    def hooks
      @hooks ||= []
    end
    
    # method that only accepts a block
    # The block is executed when an object is created via #new -> SolrDoc.new
    # The blocks scope is the instance of the object.
    def after_initialize(&blk)
      hooks << blk
    end

  end
  
  # Called by Ruby Module API
  # extends this *class* object
  def self.included(base)
    base.extend Callbacks
  end
  
  # The original object passed in to the #new method
  attr :_source_doc
  
  # Constructor
  # source_doc should be a hash or something similar
  # calls each of after_initialize blocks
  def initialize(source_doc={})
    @_source_doc = source_doc
    self.class.hooks.each do |h|
      instance_eval &h
    end
  end
  
  # the wrapper method to the @_source_doc object.
  # If a method is missing, it gets sent to @_source_doc
  # with all of the original params and block
  def method_missing(m, *args, &b)
    @_source_doc.send(m, *args, &b)
  end
  
end