namespace :solr do
  
  task :start do
    `cd jetty && java -Xmx1024M -Xms1024M -jar start.jar`
  end
  
end