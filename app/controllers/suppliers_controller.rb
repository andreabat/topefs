class SuppliersController < ApplicationController
  layout "standard"
  
  include AuthenticatedSystem
  
  before_filter :login_required
  before_filter :find_supplier, :only => [ :show, :edit, :update, :destroy,:orders ]
  
  before_filter :login_required
  require_role ["admin","account"]
  
  # GET /suppliers
  # GET /suppliers.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_suppliers.to_ext_json(:class => :supplier, :count => Supplier.count) }
    end
  end


  def orders
     
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { 
        render :json => @supplier.orders.to_ext_json(:class => :order,:include=>{:user=>{:only=>"login"}}, :count => @supplier.orders.size) 
        }
      
    end
  end

  # GET /suppliers/1
  def show
    render :action=>"edit"
    # show.html.erb
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new(params[:supplier])
    # new.html.erb
  end

  # GET /suppliers/1/edit
  def edit
    # edit.html.erb
  end
 
  # POST /suppliers
  def create
    @supplier = Supplier.new(params[:supplier])

    respond_to do |format|
      if @supplier.save
         
        format.ext_json { render :json => @supplier.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @supplier.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /suppliers/1
  def update
    respond_to do |format|
      if @supplier.update_attributes(params[:supplier])
        format.ext_json { render :json => @supplier.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @supplier.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /suppliers/1
  def destroy
    @supplier.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_supplier
      @supplier = Supplier.find(params[:id])
    end
    
    def find_suppliers
      pagination_state = update_pagination_state_with_params!(:supplier)
      @suppliers = Supplier.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(:supplier)))
    end

end
