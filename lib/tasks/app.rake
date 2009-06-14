require 'rubygems'
require 'find'
require 'rsolr'
require 'nokogiri'

require 'nwda-lib/nwda'

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
    
    #TODO: This runs out of memory for a very large directory. Optimize not to put everything in 
    #memory at once. 
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
          ead = NWDA::Mappers::EAD.new(path)
          solr.add(ead.doc)
        end
      end
      puts "Sending commit to Solr..."
      solr.commit
      puts "Complete."
      puts "Total Time: #{Time.now - t}"
    end
  
  
    # *************************************************************** #
    # Index Herbarium export
    # *************************************************************** #
    
    desc 'Index herbarium export file located at FILE=<location-of-file>'
    task :herbarium => :environment do
      t = Time.now
      
      herbarium_export_file = ENV['FILE']
      raise "Invalid file. Set the file by using the FILE argument." unless File.exists?(herbarium_export_file.to_s) and File.file?(herbarium_export_file.to_s)
      
      solr = Blacklight.solr
      
      if File.file? herbarium_export_file and herbarium_export_file.to_s =~ /^.*\.xml$/
          xml = Nokogiri::XML(open(herbarium_export_file))
          xml.xpath('/metadata/record').each do |record| 
            doc = NWDA::Mappers::Herbarium.new(record)
            #puts doc.inspect
            solr.add(doc.doc)
          end
      end
      puts "Sending commit to Solr..."
      solr.commit
      puts "Complete."
      puts "Total Time: #{Time.now - t}"
    end

  
  # *************************************************************** #
  # Index City of Pullman Collection
  # *************************************************************** #
  
  desc 'Index City of Pullman Collection located at FILE=<location-of-file>'
  task :pullman => :environment do
    t = Time.now
    
    pullman_export_file = ENV['FILE']
    raise "Invalid file. Set the file by using the FILE argument." unless File.exists?(pullman_export_file.to_s) and File.file?(pullman_export_file.to_s)
    
    solr = Blacklight.solr
    
    if File.file? pullman_export_file and pullman_export_file.to_s =~ /^.*\.xml$/
        xml = Nokogiri::XML(open(pullman_export_file))
        xml.xpath('/rdf:RDF/rdf:Description').each do |record| 
          doc = NWDA::Mappers::Pullman.new(record)
          #puts doc.inspect
          solr.add(doc.doc)
        end
    end
    puts "Sending commit to Solr..."
    solr.commit
    puts "Complete."
    puts "Total Time: #{Time.now - t}"
  end
  
  # *************************************************************** #
  # Index UW Special Collections
  # *************************************************************** #
  
  desc 'Index UW-CDM located at FILE=<location-of-file>'
  task :uwcdm => :environment do
    t = Time.now
    
    export_file = ENV['FILE']
    raise "Invalid file. Set the file by using the FILE argument." unless File.exists?(export_file.to_s) and File.file?(export_file.to_s)
    
    solr = Blacklight.solr
    
    if File.file? export_file and export_file.to_s =~ /^.*\.xml$/
        xml = Nokogiri::XML(open(export_file))
        xml.xpath('/OAI-PMH/ListRecords/record[1]').each do |record| 
          doc = NWDA::Mappers::UW.new(record)
          #puts doc.inspect
          solr.add(doc.doc)
        end
    end
    puts "Sending commit to Solr..."
    solr.commit
    puts "Complete."
    puts "Total Time: #{Time.now - t}"
  end
  
  # *************************************************************** #
  # Index Baseball
  # *************************************************************** #
  
  desc 'Index baseball records located at FILE=<location-of-file>'
  task :baseball => :environment do
    t = Time.now
    
    export_file = ENV['FILE']
    raise "Invalid file. Set the file by using the FILE argument." unless File.exists?(export_file.to_s) and File.file?(export_file.to_s)
    
    solr = Blacklight.solr
    
    if File.file? export_file and export_file.to_s =~ /^.*\.xml$/
        xml = Nokogiri::XML(open(export_file))
        xml.xpath('/metadata/record').each do |record| 
          doc = NWDA::Mappers::Baseball.new(record)
          #puts doc.inspect
          solr.add(doc.doc)
        end
    end
    puts "Sending commit to Solr..."
    solr.commit
    puts "Complete."
    puts "Total Time: #{Time.now - t}"
  end
  
  # *************************************************************** #
  # Index WSU Theses
  # *************************************************************** #
  
  desc 'Index WSU theses located at FILE=<location-of-file>'
  task :theses => :environment do
    t = Time.now
    
    export_file = ENV['FILE']
    raise "Invalid file. Set the file by using the FILE argument." unless File.exists?(export_file.to_s) and File.file?(export_file.to_s)
    
    solr = Blacklight.solr
    
    if File.file? export_file and export_file.to_s =~ /^.*\.xml$/
        raw = File.read(export_file)
        # remove the default namespace,
        # otherwise every query needs a "default:" prefix,
        # and a namespace option
        raw.gsub!(/xmlns=".*"/, '')
      
        xml = Nokogiri::XML(raw)
        xml.xpath('/OAI-PMH/ListRecords/record[1]').each do |record| 
          doc = NWDA::Mappers::Theses.new(record)
          #puts doc.inspect
          #solr.add(doc.doc)
        end
    end
    puts "Sending commit to Solr..."
    solr.commit
    puts "Complete."
    puts "Total Time: #{Time.now - t}"
  end
  # *************************************************************** #
    end # end the index namespace
end