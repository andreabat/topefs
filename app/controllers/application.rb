# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  include AuthenticatedSystem
  include ExceptionLoggable
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem
  
  helper :all # include all helpers, all the time
  before_filter :login_required
  before_filter :set_version,:set_sizes
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b00e56a724da1db6da215ffe3351b543'

    ActiveRecord::Base.include_root_in_json=false

  
  def set_version
      return if @app_version
       @app_version="1.0.0"
       @app_name  = "Top Easy Financial System"
       @app_logo    = "/images/top_logo.png"   
  end
 
 def set_sizes

   @default_grid_page_size = 20
 end

  
  
  
  def access_denied
    logger.info("Tentativo di eseguire l'operazione #{action_name} in #{controller_name} da parte di #{current_user.login if current_user!=:false}")
    if logged_in?
      logger.error("Tentativo di eseguire l'operazione #{action_name} in #{controller_name} da parte di #{current_user.login if current_user!=:false}")
      
      respond_to do |format|
        format.html  do
          render :text => "<b>Non siete autorizzato con il vostro profilo ad accedere alla risorsa specificata.</b>",:layout=>"standard"
        end
        
        format.ext_json do
          render :json=>{:success=>false,:errors=>["Non siete autorizzati con il vostro profilo ad eseguire l'operazione richiesta."]}
        end
        format.json do
          render :json=>{:success=>false,:errors=>["Non siete autorizzati con il vostro profilo ad eseguire l'operazione richiesta."]}
        end
        
      end
    else
      super
    end
  end
end
