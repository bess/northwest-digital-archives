require_dependency 'vendor/plugins/blacklight/app/controllers/application_controller.rb'

class ApplicationController
  before_filter :activate_authlogic
end