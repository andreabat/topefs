class ProceedsController < ApplicationController
 
  include AuthenticatedSystem
  before_filter :login_required
  
  require_role "account"
  require_role "admin",:for=>[:create]
  
  def index
    
    @project=   Project.find(  params[:project_id] ) if      params[:project_id]
    @invoice = Invoice.find(params[:invoice_id])  if params[:invoice_id]
   
    
  respond_to do |format|
      format.html   {render :layout =>"standard" } # index.html.erb (no data required)
      format.ext_json { 
        f = find_proceeds
        
        render :json => f.to_ext_json(:class => :proceed, :count => @count,:include=>{:user=>{:only=>"login"},:invoice=>{:only=>"code"}}) 
      }
    end
  
  end
   
   def delete
         Proceed.delete(params[:id])
           render :json=> {:success => true}.to_json
   end
  
 def create
     @object = Proceed.new(params[:proceed])
     @object.amount = params[:proceed][:amount].sub(/,/,".")
     @object.user_id = current_user.id
     if @object.save
       @invoice=@object.invoice
       render :json=> {:success => true ,:income=>@invoice.income}.to_json
       #:total=>@invoice.total,:imponibile=>@invoice.imponibile,
     else
       puts @object.errors
       render :json =>  {:success => false}.to_json
     end
 end
  protected
  
  def  find_proceeds
    pagination_state = update_pagination_state_with_params!(:proceed)
      condition = {:conditions => "project_id="+params[:project_id]} if params[:project_id]
      condition = {:conditions => "invoice_id="+params[:invoice_id]} if params[:invoice_id]
      @count = Proceed.count(:all,options_from_search(:proceed).merge(condition))
      @proceeds= Proceed.find(:all,options_from_pagination_state(pagination_state).merge(options_from_search(:proceed)).merge(condition))
  end
  
  
end
