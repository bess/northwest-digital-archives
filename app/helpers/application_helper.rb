require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'

module ApplicationHelper
  
  # given a doc, an action_name, and the name of a specific partial, 
  # this method attempts to render the named partial template
  # if this value is blank (nil/empty) the "default" is used
  # if the partial is not found, the "default" partial is rendered instead
  def render_specified_document_partial(doc, action_name, partial_name)
    begin
      render :partial=>"catalog/_#{action_name}_partials/#{partial_name}", :locals=>{:document=>doc}
    rescue ActionView::MissingTemplate
      render :partial=>"catalog/_#{action_name}_partials/default", :locals=>{:document=>doc}
    end
  end
  
  # id is a solr document id
  # composite is usually the result of solr_doc.ead.navigation (or some other instance of MaterialGirl::Composite)
  def render_navigation_level(id, composite, &block)
    html = "<ul>"
    composite.children.each do |node|
      node_id = node.object.nil? ? node.children.first.object[:id] : node.object[:id]
      v = yield(node)
      html << "<li>#{v}"
      descendant_ids = node.descendants.map{|d|d.object ? d.object[:id] : nil}
      if node_id == id or descendant_ids.include?(id) and node.children.size > 0
        html << render_navigation_level(id, node, &block)
      end
      html << "</li>"
    end
    html << "</ul>"
  end
  
  # renders the complete navigation tree
  # id is a solr_doc id
  # navigation is the result of solr_doc.ead.navigation
  def contextual_navigation_tree(id, navigation)
    render_navigation_level(id, navigation) do |node|
      if node.object
        link_to_unless_current node.value, catalog_path(node.object[:id])
      else
        link_to_unless_current node.value, catalog_path(node.children.first.object[:id])
      end
    end
  end
  
end