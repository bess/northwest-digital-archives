#
# This will eventually go back into BL!
#

require_dependency 'blacklight/solr/document/ead.rb'

class Blacklight::Solr::Document::EAD::Document
  
  def navigation
    @navigation ||= (
      res = Blacklight.solr.find({
        :qt => :document,
        # link the navigation documents together by their "hierarchy_scope" fields
        # :phrases is a quoted solr "q" param
        :phrases=>{:hierarchy_scope=>@solr_doc[:hierarchy_scope]},
        # important: we only need to fields...
        :fl => 'id,hierarchy',
        # we need the entire hierarchy
        :rows=>5000
      })
      MaterialGirl.parse(res.docs) {|d| d[:hierarchy].split('::') }
    )
  end
  
end