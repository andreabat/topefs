class BudgetsController < ApplicationController
  include AuthenticatedSystem
  before_filter :find_budget, :only => [ :edit, :update, :list_item_data]
  
  #before_filter :login_required
#  access_control :new => '(admin)'
  layout "standard"

  # GET /budgets
  # GET /budgets.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      f = find_budgets
      format.ext_json { render :json => f.to_ext_json(:class => :budget, 
                      :count => f.length,
                      :methods=>[:total_budget_costs,:total_budget_invoices,:total_budget_pricings],
                      :include=>{:user=>{:only=>"login"}}) }
      
    end
  end

 def categories
    render :json => Category.find(:all).to_ext_json(:class => :category)    
 end

  # GET /budgets/1
  def show
     render :action=>"edit"
  end

  # GET /budgets/new
  def new
    
  if(params[:from])
    origbudget= Budget.find(params[:from])
    @budget = origbudget.clone
    @budget.title=params[:name]
    #anche gli items 
     origbudget.budgetitems.each{|bi|@budget.budgetitems << bi.clone}
else
    @budget = Budget.new(params[:budget])
    @budget.user_id=current_user.id
    @budget.project_id=params[:project_id]
    @budget.title=params[:name]
  end
  
    
    
   respond_to do |format|
          if @budget.save
            format.ext_json { render :json => {:success => true,:budget_id=>@budget.id}.to_json }
          else
            format.ext_json { render :json => {:success => false}.to_json }
        end
   end 
 end

  # GET /budgets/1/edit
  def edit
   #retrieve data for items
    
  end

  # POST /budgets
  def create
    @budget = budget.new(params[:budget])

    respond_to do |format|
      if @budget.save
        flash[:notice] = 'budget was successfully created.'
        format.ext_json { render :json => @budget.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @budget.to_ext_json(:success => false) }
      end
    end
  end

  def list_item_data
    
    render :json=>@budget.budgetitems.to_json(:include=>{:category=>{:only=>"name"}})
    
  end

  def budget_item_data
        if !params[:id]
          @budgetitem = Budgetitem.new(params[:budgetitem]) 
         ret =@budgetitem.save
       else
        @budgetitem=Budgetitem.find(params[:id])
         ret =   @budgetitem.update_attributes(params[:budgetitem])
       end
      
      respond_to do |format|
      if ret
        format.ext_json { render :json => @budgetitem.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @budgetitem.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /budgets/1
  def update
    respond_to do |format|
      if @budget.update_attributes(params[:budget])
        flash[:notice] = 'budget was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to budgets_url } }
      else
        format.ext_json { render :json => @budget.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /budgets/1
  def destroy
    #propriamente elimina i budgeitems..
    #un budget non si elimina per il momento....
    #@budget.destroy
    params[:ids].split.each{|i| Projectitem.destroy(i)}
    render :json=>{:success=>true}
    
    
  end
  
  protected
  

  
    def find_budget
      @budget = Budget.find(params[:id])
    end
    
    def find_budgets
      pagination_state = update_pagination_state_with_params!(:budget)
      @budgets = Budget.find(:all,options_from_pagination_state(pagination_state).merge(options_from_search(:budget)).merge({:conditions => "project_id="+params[:project_id]}))
  end
  
#  def find_active_budgets
#      pagination_state = update_pagination_state_with_params!(:budget)
#      @budgets = budget.find(:all,options_from_pagination_state(pagination_state).merge(options_from_search(:budget)).merge({:conditions => "status_id=1"}))
#    end

end
