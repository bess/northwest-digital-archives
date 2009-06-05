# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

# The name of your project 
PROJECT = "Blacklight" 
# Your name, used in packaging. 
MY_NAME = "Bess Sadler" 
# Your email address, used in packaging. 
MY_EMAIL = "bess@virginia.edu" 
# Short summary of your project, used in packaging. 
PROJECT_SUMMARY = "Blacklight is open source discovery software. Libraries (or anyone else) may use blacklight to enable searching and browsing of their collections online. Blacklight uses Solr to index and search text and/or metadata, and it has a highly configurable Ruby on Rails front-end. Currently, Blacklight can index, search, and provide faceted browsing for MaRC records and several kinds of XML documents, including TEI, EAD, and GDMS. Blacklight was developed at the University of Virginia Library and is made public under an Apache 2.0 license." 
# The project's package name (as opposed to its display name). Used for 
# RubyForge connectivity and packaging. 
UNIX_NAME = "blacklight" 
# Your RubyForge user name. 
RUBYFORGE_USER = ENV["RUBYFORGE_USER"] || "eos8d" 
# Directory on RubyForge where your website's files should be uploaded. 
RUBYFORGE_PATH = "/var/www/gforge-projects/blacklight/" 
# Output directory for the rdoc html files. 
# If you don't have a custom homepage, and want to use the RDoc 
# index.html as homepage, just set it to WEBSITE_DIR. 
RDOC_HTML_DIR = "doc/plugins/blacklight/" 
PROJECT_VERSION = "2.0.0" # e.g., "1.0.2"
# where do our package files go? 
target = './dist'
# Clobber the package files when re-building
CLOBBER.include("#{target}/*") 
# Additional RDoc formatted files, besides the Ruby source files. 
RDOC_FILES = FileList["README.rdoc", "Changes.rdoc"]
CURRENT_SVN_BRANCH = "http://blacklight.rubyforge.org/svn/branches/rails-engines/trunk/"


# Run the rspec for the plugins if rake is invoked without arguments. 
# task "default" => ["spec:plugins"] 
# task "test" => ["spec:plugins"] 

desc "Generate rdoc for the plugins." 
task "rdoc" => ["doc:plugins"]

desc "Upload website to RubyForge. scp will prompt for your RubyForge password." 
task "publish-rdoc" => ["rdoc"] do 
  rubyforge_path = "/var/www/gforge-projects/#{UNIX_NAME}/" 
  sh "scp -r #{RDOC_HTML_DIR}/* " + 
    "#{RUBYFORGE_USER}@rubyforge.org:#{RUBYFORGE_PATH}", 
    :verbose => true 
end 

# The "prepare-release" task makes sure your tests run, and then generates 
# files for a new release. 
desc "Run tests, generate RDoc and create packages." 
task "prepare-release" => ["clobber"] do 
  puts "Preparing release of #{PROJECT} version #{PROJECT_VERSION}" 
  Rake::Task["test"].invoke 
  Rake::Task["rdoc"].invoke 
  Rake::Task["package"].invoke 
end 

desc "prepare a package"
task "package" do
  puts "building release... "
  # check for dist folder
  mkdir_p target
  # clean up any previous checkouts
  puts "removing previous package files..."
  sh "rm -rf #{target}/*"
  # svn export the subversion url
  puts "exporting svn contents from #{CURRENT_SVN_BRANCH} to #{target}/#{UNIX_NAME}-#{PROJECT_VERSION}"
  sh "svn export #{CURRENT_SVN_BRANCH} #{target}/#{UNIX_NAME}-#{PROJECT_VERSION}"
  # gzip the whole thing and name it with the version number
  puts "zipping #{UNIX_NAME}-#{PROJECT_VERSION}.tgz"
  sh "cd #{target}; tar czvf #{UNIX_NAME}-#{PROJECT_VERSION}.tgz #{UNIX_NAME}-#{PROJECT_VERSION}"
end

task "rubyforge-setup" do 
  unless File.exist?(File.join(ENV["HOME"], ".rubyforge")) 
    puts "rubyforge will ask you to edit its config.yml now." 
    puts "Please set the `username' and `password' entries" 
    puts "to your RubyForge username and RubyForge password!" 
    puts "Press ENTER to continue." 
    $stdin.gets 
    sh "rubyforge setup", :verbose => true
    sh "rubyforge config blacklight", :verbose => true
    puts "you might need to put these lines in ~/.rubyforge/auto-config.yml:
processor_ids:
  Any: 8000
  "
  end 
end 


task "rubyforge-login" => ["rubyforge-setup"] do 
  # Note: We assume that username and password were set in 
  # rubyforge's config.yml. 
  sh "rubyforge login", :verbose => true 
end 

task "publish-packages" => ["prepare-release", "rubyforge-login"] do 
  # Upload packages under pkg/ to RubyForge 
  # This task makes some assumptions: 
  # * You have already created a package on the "Files" tab on the 
  #   RubyForge project page. See pkg_name variable below. 
  # * You made entries under package_ids and group_ids for this 
  #   project in rubyforge's config.yml.  If not, eventually read 
  #   "rubyforge --help" and then run "rubyforge setup". 
  pkg_name = ENV["PKG_NAME"] || UNIX_NAME 
  cmd = "rubyforge add_release #{UNIX_NAME} #{pkg_name} " + 
        "#{PROJECT_VERSION} #{UNIX_NAME}-#{PROJECT_VERSION}" 
  cd "#{target}" do 
    #puts "#{cmd}.tgz"
    sh(cmd + ".tgz", :verbose => true) 
  end 
end 


