#
# This will eventually go back into BL!
#

require_dependency 'blacklight/solr/document/ead.rb'

class Blacklight::Solr::Document::EAD::Document
  
  # Provides a navigation method to docs that mixin this module.
  # This method returns a composite/tree object.
  # It makes a query to solr using the :hierarchy_scope field as a filter,
  # the values used is the value of THIS solr docs :hierarchy_scope value.
  # The fl is set to "id,hierarchy" and also sets a very hi :rows value
  # to ensure that all related docs are returned.
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