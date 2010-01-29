class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  layout "standard"
  before_filter :login_required
  require_role ["admin","account"]
  
  # render new.rhtml
  def new
    @roles = Role.find(:all)
    
  end

  def show
    edit
    @update=false
    render :action=>"edit"
  end


  def edit
     
   @user = User.find(params[:id],:select=>"id,login,active,nominativo,hourly_cost")
   @roles = Role.find(:all)
   @selected = @user.roles.to_json
   @j_form_values=@user.to_ext_json(:output_format => :form_values)
    @update=true   
  end

  def index
      
      respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_users.to_ext_json(:class => :user , :count => User.count) }
    end
    
  end

 def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    #unless @user.roles.include?(Role.find(x)) 
    @user.roles.clear
    params[:roles].split(',').each {|x| @user.roles<<Role.find(x) };
    respond_to do |format|
       
        format.ext_json { render :json => @user.to_ext_json(:success => true) }
       
    
    end
  end
   

  def create
  #  cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    params[:roles].split(',').each {|x| @user.roles<< Role.find(x)};
    
    
    @user.save
    respond_to do |format|
      if @user.errors.empty?
                 format.ext_json { render :json => @user.to_ext_json(:success=>true) }
      else
                 format.ext_json { render :json => @user.to_ext_json(:success => false) }
      end
    end
      
      
  end
protected 
def find_users
      pagination_state = update_pagination_state_with_params!(:user)
      @users = User.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(:user)))
      #@user.collect!{|x|x[]}
    end

end
