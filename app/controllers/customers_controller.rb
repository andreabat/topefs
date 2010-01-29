class CustomersController < ApplicationController

  before_filter :find_customer, :only => [ :show, :edit, :update, :destroy ]
  require_role "updater", :only => [:index]
  require_role "viewer", :only => [:index]


  layout "standard"
  # GET /customers
  # GET /customers.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_customers.to_ext_json(:class => :customer, :count => Customer.count) }
    end
  end

  # GET /customers/1
  def show
    # show.html.erb
    render :action=>"edit"
  end
def projects
  @customer=Customer.find(params[:customer_id])
  respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json {
      pagination_state = update_pagination_state_with_params!(:project)
       find_options = {:order => "#{pagination_state[:sort_field]} #{pagination_state[:sort_direction]}"} unless pagination_state[:sort_field].blank?
       
      @projects = Project.find_all_by_customer_id(@customer.id,find_options)
      logger.debug(@projects.to_ext_json(:class => :project,:include=>{:status=>{:only=>"status"}}, :count => @projects.size) )
      render :json => @projects.to_ext_json(:class => :project,:include=>{:status=>{:only=>"status"}}, :count => @projects.size) }
    end
end
  # GET /customers/new
  def new
    @customer = Customer.new(params[:customer])
    # new.html.erb
  end

  # GET /customers/1/edit
  def edit
    # edit.html.erb
  end

  # POST /customers
  def create
    @customer = Customer.new(params[:customer])

    respond_to do |format|
      if @customer.save
        flash[:notice] = 'Customer was successfully created.'
        #format.ext_json { render(:update) {|page| page.redirect_to customers_url } }
        format.ext_json { render :json => @customer.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @customer.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /customers/1
  def update
    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        flash[:notice] = 'Customer was successfully updated.'
#        format.ext_json { render(:update) {|page| page.redirect_to customers_url } }
        format.ext_json { render :json => @customer.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @customer.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /customers/1
  def destroy
    @customer.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_customer
      @customer = Customer.find(params[:id])
    end
    
    def find_customers
      pagination_state = update_pagination_state_with_params!(:customer)
      @customers = Customer.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(:customer)))
    end

end
