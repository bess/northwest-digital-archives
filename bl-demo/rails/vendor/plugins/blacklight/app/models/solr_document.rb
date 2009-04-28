class SolrDocument
  
  include Blacklight::Solr::Doc
  
  after_initialize do
    extend Blacklight::Solr::Doc::Ext::Common
    extend Blacklight::Solr::Doc::Ext::Marc if marc?
  end
  
end