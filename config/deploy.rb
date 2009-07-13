# This is an example capistrano recipe for deploying blacklight. 
# We use it to deploy the application at demo.blacklightopac.org
# Your milage may vary for local usage. 

set :application, "nwda"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# name of the user who will own this application on the server 
set :user, "deployer"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
 set :deploy_to, "/usr/local/projects/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :scm_passphrase, ""
set :branch, "master"
set :deploy_via, :remote_cache
set :repository,  "git@github.com:bess/northwest-digital-archives.git"


# If you run your app, your webserver (httpd) and/or your database on different servers, you can 
# set each of these to unique values
set :domain, "alliancedev.uoregon.edu"
role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :runner, "deployer"
set :rails_env, "production"

# This assumes that your database.yml file is NOT in subversion,
# but instead is in your deploy_to/shared directory. Database.yml
# files should *never* go into subversion for security reasons.
task :after_update_code do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{deploy_to}/shared/config/solr.yml #{release_path}/config/solr.yml"
  run "cp #{deploy_to}/current/jetty/solr/conf/schema.xml #{deploy_to}/shared/solr/conf/schema.xml"
  run "sudo /sbin/service tomcat6 restart"
end


# ========================
# Reindex the Orbis Cascade data
# ========================


namespace :reindex do
  
  before "reindex:all", "reindex:baseball"
  before "reindex:all", "reindex:herbarium"
  before "reindex:all", "reindex:pullman"
  before "reindex:all", "reindex:theses"
  before "reindex:all", "reindex:ead"
  
  task :baseball do   
    run "cd #{deploy_to}/current; rake app:index:baseball FILE=#{deploy_to}/../raw_data/baseball_export.xml"
  end
  
  task :pullman do   
    run "cd #{deploy_to}/current; rake app:index:pullman FILE=#{deploy_to}/../raw_data/cityofpullmancollection.xml"
  end
  
  task :herbarium do   
    run "cd #{deploy_to}/current; rake app:index:herbarium FILE=#{deploy_to}/../raw_data/herbarium_export.xml"
  end
  
  task :theses do   
    run "cd #{deploy_to}/current; rake app:index:theses FILE=#{deploy_to}/../raw_data/wsu-theses.xml"
  end

  task :ead do   
    run "cd #{deploy_to}/current; rake app:index:ead FILE=#{deploy_to}/../raw_data/ead/*/*.xml"
  end
  
  task :all do
    puts "Reindexing everything ... "
  end

end

# ========================
# For mod_rails apps
# ========================


namespace :deploy do
  task :start, :roles => :app do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
  
  task :restart, :roles => :app do
    # this doesn't work. --bess
    #run "pkill java"
    #run "cd #{deploy_to}/current/jetty; nohup java -jar start.jar &"
    
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
  
  task :after_symlink, :roles => :app do
    #run "cp #{deploy_to}/current/vendor/plugins/blacklight/config/initializers/blacklight_config.rb #{deploy_to}/current/config/initializers/blacklight_config.rb"
    # this next step shouldn't be necessary for rails 2.3, and yet the installation on polaris.lib won't 
    # run without it
    #run "ln -nfs #{deploy_to}/current/vendor/plugins/blacklight/app/controllers/application_controller.rb #{deploy_to}/current/vendor/plugins/blacklight/app/controllers/application.rb"
  end
  
  task :after_symlink do
    # stop solr

  end
end
