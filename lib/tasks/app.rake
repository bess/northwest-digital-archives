require 'rubygems'
require 'find'
require 'rsolr'
require 'nokogiri'
 
require 'nwda-lib/nwda'
 
def require_env_file
  raise("The FILE environment variable is required!") if ENV['FILE'].to_s.empty?
  ENV['FILE']
end
 
namespace :app do
  
  namespace :index do
    
    desc 'Index all of the sample data for the NWDA demo'
    task :all => :environment do
      require 'ead_solr_mapper'
      
      ENV['FILE'] = '../raw_data/herbarium_export.xml'
      Rake::Task["app:index:herbarium"].invoke
      
      ENV['FILE'] = '../raw_data/baseball_export.xml'
      Rake::Task["app:index:baseball"].invoke
      
      ENV['FILE'] = '../raw_data/wsu-theses.xml'
      Rake::Task["app:index:theses"].invoke
      
      ENV['FILE'] = '../raw_data/cityofpullmancollection.xml'
      Rake::Task["app:index:pullman"].invoke
      
      ENV['FILE']='../raw_data/ead/*/*.xml'
      Rake::Task["app:index:ead"].reenable
      Rake::Task["app:index:ead"].invoke

    end
      
    desc "Index an EAD file at FILE=<location-of-file> using the lib/ead_mapper class."
    task :ead => :environment do
      solr = Blacklight.solr
      
      if ENV['FILE'].nil?
        ENV['FILE']='../raw_data/ead/*/*.xml'
      end
      
      require 'ead_solr_mapper'
      t = Time.now
      input_file = require_env_file
      if input_file =~ /\*/
        files = Dir[input_file].collect
      else
        files = [input_file]
      end
      
      files.each_with_index do |f,index|
        mapper = EADSolrMapper.new f
        # delete the previous set of docs in this collection...
        solr.delete_by_query "collection_id:\"#{mapper.collection_id}\""
        solr.add mapper.map
      end
      solr.commit
      puts "Total Time: #{Time.now - t}"
    end
    
    # *************************************************************** #
    # Index Herbarium export
    # *************************************************************** #
    
    desc 'Index herbarium export file located at FILE=<location-of-file>'
    task :herbarium => :environment do
      t = Time.now
      
      if ENV['FILE'].nil?
        ENV['FILE'] = '../raw_data/herbarium_export.xml'
      end
      herbarium_export_file = ENV['FILE']
      raise "Invalid file. Set the file by using the FILE argument." unless File.exists?(herbarium_export_file.to_s) and File.file?(herbarium_export_file.to_s)
      
      solr = Blacklight.solr
      
      puts "indexing #{herbarium_export_file}"
      
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
    
    if ENV['FILE'].nil?
      ENV['FILE'] = '../raw_data/cityofpullmancollection.xml'
    end
    pullman_export_file = ENV['FILE']
    raise "Invalid file. Set the file by using the FILE argument." unless File.exists?(pullman_export_file.to_s) and File.file?(pullman_export_file.to_s)
    
    solr = Blacklight.solr
    
    puts "indexing #{pullman_export_file}"
    
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
    
    if ENV['FILE'].nil?
      ENV['FILE'] = '../raw_data/baseball_export.xml'
    end
    export_file = ENV['FILE']
    
    puts "indexing #{export_file}"
    
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
    
    if ENV['FILE'].nil?
      ENV['FILE'] = '../raw_data/wsu-theses.xml'
    end
    export_file = ENV['FILE']
    raise "Invalid file. Set the file by using the FILE argument." unless File.exists?(export_file.to_s) and File.file?(export_file.to_s)
    
    solr = Blacklight.solr
    
    puts "Indexing #{export_file}"
    
    if File.file? export_file and export_file.to_s =~ /^.*\.xml$/
        raw = File.read(export_file)
        # remove the default namespace,
        # otherwise every query needs a "default:" prefix,
        # and a namespace option
        raw.gsub!(/xmlns=".*"/, '')
      
        xml = Nokogiri::XML(raw)
        xml.xpath('/OAI-PMH/ListRecords/record').each do |record|
          doc = NWDA::Mappers::Theses.new(record)
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
    end # end the index namespace
end