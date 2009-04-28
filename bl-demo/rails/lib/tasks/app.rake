require 'find'


namespace :app do
  
  namespace :index do
    
    # *************************************************************** #
    # Index marc files
    # Note: solrmarc is probably better for production use, but this
    # is a good place to start 
    # *************************************************************** #
    
    desc 'Index a marc file at FILE=<location-of-file> using the lib/marc_mapper class.'
    task :marc => :environment do
      
      t = Time.now
      
      marc_file = ENV['FILE']
      raise "Invalid file. Set the by using the FILE argument." unless File.exists?(marc_file.to_s)
      
      solr = Blacklight.solr
      
      mapper = MARCMapper.new
      mapper.from_marc_file(marc_file) do |doc,index|
        puts "#{index} -- adding doc w/id : #{doc[:id]} to Solr"
        solr.add(doc)
      end
      
      puts "Sending commit to Solr..."
      solr.commit
      puts "Complete."
      
      puts "Total Time: #{Time.now - t}"
      
    end
    
    # *************************************************************** #
    # Index EAD files 
    # *************************************************************** #
    
    desc 'Recursively index a directory of EAD files at DIR=<location-of-dir>'
    task :ead => :environment do
      t = Time.now
      
      ead_dir = ENV['DIR']
      raise "Invalid directory. Set the directory by using the DIR argument." unless File.exists?(ead_dir.to_s) and File.directory?(ead_dir.to_s)
      
      solr = Blacklight.solr
      
      Find.find(ead_dir) do |path| 
        if File.directory? path
           puts "Indexing #{path}"
        end
        if File.file? path and path.to_s =~ /^.*\.xml$/
          ead = EADMapper.new(path)
          solr.add(ead.doc)
        end
      end
      puts "Sending commit to Solr..."
      solr.commit
      puts "Complete."
      puts "Total Time: #{Time.now - t}"
    end
  end
  
end