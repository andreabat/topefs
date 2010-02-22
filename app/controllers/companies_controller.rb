class CompaniesController < ApplicationController
  require_role "account"
  require_role "admin",:for=>[:create,:update,:new,:edit]

 layout "standard"
  before_filter :find_company, :only => [ :show, :edit, :update, :destroy ]

  # GET /companies
  # GET /companies.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_companies.to_ext_json(:class => :company, :count => Company.count) }
    end
  end

  # GET /companies/1
  def show
    # show.html.erb
  end

  # GET /companies/new
  def new
    @company = Company.new(params[:company])
    # new.html.erb
  end

  # GET /companies/1/edit
  def edit
    # edit.html.erb
  end

  # POST /companies
  def create
    @company = Company.new(params[:company])

    respond_to do |format|
      if @company.save
        flash[:notice] = 'Company was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to companies_url } }
      else
        format.ext_json { render :json => @company.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /companies/1
  def update
    respond_to do |format|
      if @company.update_attributes(params[:company])
      #  flash[:notice] = 'Company was successfully updated.'
        format.ext_json { render :json => @company.to_ext_json(:success => true)  }
      else
        format.ext_json { render :json => @company.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_company
      @company = Company.find(params[:id])
    end
    
    def find_companies
      pagination_state = update_pagination_state_with_params!(:company)
      @companies = Company.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(:company)))
    end

end
