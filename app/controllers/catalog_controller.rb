class CatalogController < ApplicationController

  require_dependency 'vendor/plugins/blacklight/app/controllers/catalog_controller.rb'

  # get single document from the solr index
  def show
    @response = get_solr_response_for_doc_id
    @document = SolrDocument.new(@response.docs.first)
    @address = Address.find_by_name(@document[:institution_facet])
    respond_to do |format|
      format.html {setup_next_and_previous_documents}
      format.xml  {render :xml => @document.marc.to_xml}
      format.refworks
      format.endnote
    end
  rescue ActiveRecord::RecordNotFound 
     logger.error("Attempt to access invalid id: #{params[:id]}") 
     flash[:notice] = "Sorry, I can't find the item you requested." 
     redirect_to :action => 'index' 
  rescue 
       logger.error("Error encountered when trying to access: #{params[:id]}") 
       flash[:notice] = "Sorry, you seem to have encountered an error." 
       redirect_to :action => 'index', :q => nil , :f => nil
  end

end