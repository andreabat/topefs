class ProjectsController < ApplicationController
   include AuthenticatedSystem
  layout "standard"
  before_filter :find_project, :only => [ :show, :edit, :update, :destroy,:finance_summary,:customer_list,:edititems,:list_item_data ]
  before_filter :find_active_projects, :only => [ :active]
  before_filter :login_required

#  require_role "updater",:for=>[:index]
#  require_role "viewer",:for=>[:index]
#  require_role "account",:except=>[:index]
  require_role ["admin","account"],:except=>[:index]
  #:only => [:new,:create,:update,:destory]




  # GET /projects
  # GET /projects.ext_json
  def index
    
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_projects.to_ext_json(:class => :project, :count => @count,:include=>{
                                                                            :customer=>{:only=>"ragionesociale"}}) }
    end
  end


  def finance_summary
#    @costi_vivi = Projectitem.sum(:cost,:conditions=>["(price=0 or price is null) and project_id=?",params[:id]])
    @costi_vivi = Projectitem.find(:first,:select=>"sum(cost*coalesce(quantity,1)) as vivi",:conditions=>["(price=0 or price is null) and project_id=?",params[:id]]).vivi.to_i
    @costi_vivi = 0 if @costi_vivi==nil
    @costi_fornitore = 0
    @costi_preventivati=0
    @project.projectitems.each{|p|
              @costi_fornitore+=(p.cost*(p.quantity ? p.quantity : 1) ) unless p.price==0
              @costi_preventivati+=(p.price*(p.quantity ? p.quantity : 1) ) unless p.price==0
    }
    
    @costi_ordini=0
    orders=Order.find_all_by_project_id(params[:id])
    orders.each{|x| @costi_ordini+=x.total}
    #@costi_fornitore = orders.sum(:total) unless orders==nil else     @costi_fornitore = 0
    ts = Timesheet.find_all_by_project_id(params[:id])
    @costi_personale = 0
     ts.each{|x| @costi_personale+=x.cost}
     
     @graph_costi = open_flash_chart_object(250,250, '/reports/costi_commessa/'<<params[:id], true, '/')
     @graph_finanze = open_flash_chart_object(500,250, '/reports/report1?id='<<params[:id], true, '/')     
 #   @costi_personale = ts.sum(:cost) unless ts==nil #else      @costi_personale = 0  
    render :layout=>false
  end

  # GET /projects/active
  # GET /projects/active.ext_json
  def active
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      f = find_active_projects

      format.ext_json { render  :json => f.to_ext_json(:class => :project, :count => f.length) }
      #render :template =>"projects/index"

    end
  end

  # GET /projects/1
  def show
     render :action=>"edit"
  end

  # GET /projects/new
  def new
    @project = Project.new(params[:project])
    # new.html.erb
  end

  # GET /projects/1/edit
  def edit
    # edit.html.erb
  end

  def edititems

    # edit.html.erb
  end
  # POST /projects
  def create
    @project = Project.new(params[:project])
    @project.user_id=current_user.id
    respond_to do |format|
      if @project.save
        format.ext_json { render :json => @project.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @project.to_ext_json(:success => false) }
      end
    end
  end
  
  def duplicate
    find_project
    @new_project = @project.clone
    @new_project.title = "Copia di " + @project.title
    @new_project.start = Time.now
    @new_project.end = nil

    @project.projectitems.each{|bi|
        tpi = bi.clone
        tpi.id=nil
        tpi.created_at = Time.now
        tpi.updated_at = Time.now
        @new_project.projectitems <<  tpi
    
    }

        @new_project.save
    respond_to do |format|
      format.ext_json { render :json => @new_project.to_ext_json(:success => true) }
    end
    
  end

  # PUT /projects/1
  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.ext_json { render :json => @project.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @project.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /projects/1
  def destroy
    un_deletable = @project.un_deletable
    @project.destroy if !un_deletable
   #raise  "Impossibile cancellare un progetto che contiene fatture,ordini e pagamenti" if un_deletable
    print un_deletable
    
  
    respond_to do |format|
   #   format.js  { head :ok }
      format.ext_json   {render :json=>{:success => false,:errors=>true,:msg=>"Impossibile cancellare un progetto che contiene fatture,ordini e pagamenti"}} if un_deletable
      format.ext_json   {render :json=>{:success => true,:msg=>"OK"}} if !un_deletable
      
    end
#  rescue
#    respond_to do |format|
#      format.js  { head :status => 500 }
#      format.ext_json  { render :json=>(head :ok) }
#    end
  end
  
   def list_item_data
    render :json=>@project.projectitems.to_json(
                    :include=>{:category=>{:only=>"name"} },
                    :methods=>[:invoiced,:ordered,:priced,:pricedna]
                    )
end
 def categories
   
    render :json => Category.find(:all).to_ext_json(:class => :category)    
 end

def project_item_data
        if !params[:id]
          @projectitem = Projectitem.new(params[:projectitem]) 
         ret =@projectitem.save
       else
        @projectitem=Projectitem.find(params[:id])
         ret =   @projectitem.update_attributes(params[:projectitem])
       end
      
      respond_to do |format|
      if ret
        format.ext_json { render :json => @projectitem.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @projectitem.to_ext_json(:success => false) }
      end
    end
  end  
  
  protected
  
    def find_project
      
      @project = Project.find(params[:id])
       
    end
    
    def find_projects
      pagination_state = update_pagination_state_with_params!(:project)
      all_opts = options_from_pagination_state(pagination_state).merge(options_from_search(:project))
    #  print (all_opts)
      
      @count = Project.count(:all,options_from_search(:project))
    
      @projects = Project.find(:all, all_opts )
    
  end
  
  def find_active_projects
    pagination_state = update_pagination_state_with_params!(:project)
      all_opts = options_from_pagination_state(pagination_state).merge(options_from_search(:project))
      #.merge({:conditions => "status_id=1"})
      #print (all_opts)
      all_opts[:conditions] << " and status_id=1"
      @count = Project.count(:all,options_from_search(:project))
      @projects = Project.find(:all,all_opts)
    end



end
