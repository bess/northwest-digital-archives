module Blacklight::Solr::Doc::Ext::Common
  
  # built-in/stock "flag" methods should go here...
  
  def marc?
    key? Blacklight.config[:raw_storage_field]
  end
  
end