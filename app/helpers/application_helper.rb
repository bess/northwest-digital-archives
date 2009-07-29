require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'

module ApplicationHelper
  
  # overloaded from blacklight plugin... define your local application name
  def application_name
    'NWDA Discovery Interface'
  end
  
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
  # composite is usually the result of solr_doc.ead.navigation
  # (or some other instance of MaterialGirl::Composite)
  # opts is a hash -- :max_depth is the only valid option
  # current_depth should not be used by you!
  def render_navigation_level(id, composite, opts={}, current_depth=0, &block)
    return '' if opts[:max_depth] == current_depth
    html = %(<ul class="navigation">)
    composite.children.each do |node|
      node_id = node.object.nil? ? node.children.first.object[:id] : node.object[:id]
      v = yield(node)
      html << "<li>#{v}"
      descendant_ids = node.descendants.map{|d|d.object ? d.object[:id] : nil}
      if node_id == id or descendant_ids.include?(id) and node.children.size > 0
        html << render_navigation_level(id, node, opts, current_depth+1, &block)
      end
      html << "</li>"
    end
    html << "</ul>"
  end
  
  # renders the complete navigation tree
  # id is a solr_doc id
  # navigation is the result of solr_doc.ead.navigation
  def contextual_navigation_tree(id, navigation, opts={})
    render_navigation_level(id, navigation, opts) do |node|
      if node.object
        link_to_unless_current node.value, catalog_path(node.object[:id])
      else
        link_to_unless_current node.value, catalog_path(node.children.first.object[:id])
      end
    end
  end
  
  # Used in the show view for displaying the main solr document heading
  # overloaded from blacklight plugin
  # TODO: This should go back into the plugin for the EAD guides there
  #def document_heading
    #heading = @document[Blacklight.config[:show][:heading]]
    #if @document[:unittitle_t]
    #  heading = heading.concat(': ' + @document[:unittitle_t][0])
    #end
    #heading
  #end
  
end