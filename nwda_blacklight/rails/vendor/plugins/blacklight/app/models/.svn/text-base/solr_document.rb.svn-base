class SolrDocument
  
  include Blacklight::Solr::Doc
  
  after_initialize do
    extend Blacklight::Solr::Doc::Ext::Marc if marc?
  end
  
  def marc?
    key? Blacklight.config[:raw_storage_field]
  end
  
end