
config.gem "authlogic"
config.gem 'ruby-xslt', :lib=>'xml/xslt'
config.gem 'mislav-hanna', :lib=>'hanna/rdoctask', :source=>'http://gems.github.com'
config.gem 'nokogiri', :version=>'>=1.3.1'
config.gem 'mwmitchell-material_girl', :lib=>'material_girl', :source=>'http://gems.github.com', :version=>'0.0.2'
config.gem 'cucumber', :version=>'>=0.3.5'
config.gem 'webrat', :version=>'>=0.4.4'
config.gem 'curb'
config.gem 'rspec', :lib=>"spec", :version=>'>=1.2.7'
config.gem "rspec-rails", :lib => "spec/rails"

#config.gem 'mwmitchell-rsolr-ext', :version=>'0.7.35', :lib=>'rsolr-ext', :source=>'http://github.com'

# Load up the vendorized gems:
[
  'mislav-will_paginate-2.3.8/lib/will_paginate.rb',
  'mwmitchell-rsolr-0.8.8/lib/rsolr.rb',
  'mwmitchell-rsolr-ext-0.7.35/lib/rsolr-ext.rb',
  'marc-0.2.2/lib/marc.rb'
].each do |gem_file|
  # add the lib dir of each gem to the load path, which is the variable $:
  $: << File.join(File.dirname(__FILE__), 'vendor', 'gems', File.dirname(gem_file))
  # now require the gem file, based on the last path added to $:
  require File.join($:.last, File.basename(gem_file))
end

config.after_initialize do
  require 'will_paginate_link_renderer'   # in local ./lib
  require 'taggable_pagination'           # in local ./lib
  Blacklight.init
  Mime::Type.register_alias "text/plain", :refworks
end
