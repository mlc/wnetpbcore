# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'ipaddr'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  before_filter :set_current_user
  before_filter :check_ip_range

  include Userstamp

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c862b066d8e3a1d1df3bcf1404579ba2'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  filter_parameter_logging :password

  def initialize(*args)
    super(*args)
    @alternates = []
  end

  def alternate(type, *args_for_url)
    @alternates << [url_for(*args_for_url), type]
  end

  protected
  def set_current_user
     Authorization.current_user = current_user || Authorization::GuestUser.new(get_ip_based_roles)
  end

  def get_ip_based_roles
    return [:guest] unless PBCore.config["auto_login_blocks"]

    client = IPAddr.new(request.remote_ip)
    PBCore.config["auto_login_blocks"].each do |ip, roles|
      if IPAddr.new(ip).include?(client)
        return roles.is_a?(Array) ? roles.map(&:to_sym) : [roles.to_sym]
      end
    end

    [:guest]
  end

  def check_ip_range
    if current_user && current_user.ip_block && !current_user.ip_block.include?(request.remote_ip)
      render :text => "You must log in from an allowed IP range.", :status => 403, :layout => 'application'
    end
  end

  def permission_denied
    if logged_in?
      render :text => "You are not allowed to access this action.", :status => 403
    else
      flash[:message] = "You must log in before proceeding."
      redirect_to login_path
    end
  end

  def enable_flash
    @page_has_flash = true
  end
end
