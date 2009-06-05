module NavigationHelpers
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      root_path
      
    when /the document page for id (.+)/ 
      catalog_path($1)
    
    # Add more page name => path mappings here
    
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in features/support/paths.rb"
    end
  end
end

# Cucumber 0.3
World(NavigationHelpers)

# Cucumber 0.2
=begin
World do |world|
  world.extend NavigationHelpers
  world
end
=end