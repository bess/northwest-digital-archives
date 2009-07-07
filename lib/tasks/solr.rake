namespace :solr do
  
  jetty_path = 'jetty'
  start_port = 8983
  stop_port = 8079
  stop_key = 'NWDA'
  java_opts = '-Xmx1024M -Xms1024M'
  
  task :start do
    puts "*** starting solr on port #{solr_start_port}..."
    `cd #{jetty_path} && java #{java_opts} -Djetty.port=#{start_port} -DSTOP.KEY=#{stop_key} -DSTOP.PORT=#{stop_port} -jar start.jar`#` > /dev/null 2>&1`
    puts '*** solr started'
  end
  
  task :stop do
    `cd #{jetty_path} && java -DSTOP.KEY=#{stop_key} -DSTOP.PORT=#{stop_port} -jar start.jar --stop`
  end
  
end