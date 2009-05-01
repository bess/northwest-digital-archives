class SolrDocument

  include Blacklight::Solr::Doc
  include Blacklight::Solr::Doc::Ext::Common
  include NWDA::Solr::Doc::Ext::Common

  after_initialize do
    # instance scope...
    self.extend NWDA::Solr::Doc::Ext::EAD if ead?
  end

end
