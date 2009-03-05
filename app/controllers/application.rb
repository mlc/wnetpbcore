# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  before_filter :set_current_user

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c862b066d8e3a1d1df3bcf1404579ba2'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  def initialize(*args)
    super(*args)
    @alternates = []
  end
  
  def alternate(type, *args_for_url)
    @alternates << [url_for(*args_for_url), type]
  end

  protected
  def set_current_user
     Authorization.current_user = current_user
  end
end
