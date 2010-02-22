class TimesheetController < ApplicationController
  include AuthenticatedSystem
  require_role ["account","admin","creativi"]
#  require_role "admin",:for=>[:create,:update,:new,:edit]
  before_filter :login_required

  def index

    respond_to do |format|
      format.html   {
      
      @project=Project.find(params[:project_id]) unless !params[:project_id]
      @users = User.all(:order=>:nominativo).map{|u| [u.id,u.nominativo]}
      	render :layout =>"standard" 
      } 
      if params[:uid].nil?
	      @uid = current_user.id
      else
	      @uid = params[:uid]
      end
      
      
      
      format.ext_json { 
        d =  DateTime.parse(params[:d])
        t = Timesheet.find_all_by_user_id(@uid,:conditions=>['date=?',d])
        #  ext_json{:prova=>"Ciao",:data=>d.strftime("%d %m %Y")}
        render :json=>t.to_ext_json(:class=>:timesheet,:include=>{:project=>{:only=>"title"}})
      }
    end
    end
    def create
	 
      @object = Timesheet.new(params[:timesheet]) 
      @object.current_user.id=@uid if @object.user_id.nil?
      if @object.save
        render :json => {:success => true,:id=>@object.id}.to_json
      else
        render :json => {:success => false}.to_json 
      end
      
    end
    
    def update
      @object = Timesheet.find(params[:data]) 
      if @object.update_attributes(params[:timesheet])
        render :json => {:success => true,:id=>@object.id}.to_json
      else
        render :json => {:success => false}.to_json
      end
      
    end
    
    
    def destroy
      @object = Timesheet.find(params[:data])
      @object.destroy
      render :json => {:success => true}.to_json
    end
    
    protected
    
    
  end
