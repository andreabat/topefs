class HomeController < ApplicationController
  include AuthenticatedSystem
  
  def index
    current_user()
    render :layout => "ext"  
  end
  
  def riepilogo
    render :layout => "standard"
  end
  
end