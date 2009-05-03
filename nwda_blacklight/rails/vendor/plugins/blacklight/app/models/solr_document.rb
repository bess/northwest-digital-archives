class SolrDocument
  
  include Blacklight::Solr::Doc
  
  after_initialize do
    extend Blacklight::Solr::Doc::Ext::Marc if marc?
    extend Blacklight::Solr::Doc::Ext::EAD if ead?
  end
  
  def marc?
    key? Blacklight.config[:raw_storage_field]
  end
  
  def ead?
    key? Blacklight.config[:ead_storage_field]
  end
  
end