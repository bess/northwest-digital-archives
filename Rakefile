# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

# the default rake task
# desc "run migrations and call solr:spec and solr:features"
task :default => "rake:features"

# run migrations and call solr:spec and solr:features
# desc 'run migrations and call rake:features'
#   task "test" => ["db:test:prepare", "rake:features"] do
# end

desc "Generate rdoc for the demo app and the blacklight plugin." 
task "rdoc"
    require 'hanna/rdoctask'
    Rake::RDocTask.new('rdoc') do |t| 
    t.rdoc_files.include('README.rdoc', 'LICENSE')
    t.rdoc_files.include('vendor/plugins/blacklight/*.rdoc')
    t.rdoc_files.include('lib/**/*.rb', 'config/initializers/blacklight_config.rb')
    t.rdoc_files.include('vendor/plugins/blacklight/app/controllers', 'vendor/plugins/blacklight/app/helpers', 'vendor/plugins/blacklight/app/models')
    t.rdoc_files.include('vendor/plugins/blacklight/lib')
    #t.rdoc_files.include('vendor/plugins/blacklight/vendor/gems')
    t.options << "--exclude=vendor/plugins/blacklight/lib/experiments"
  
    t.main = 'README.rdoc'
    t.title = "NWDA Blacklight Documentation"
    t.rdoc_dir = 'doc' 
end
