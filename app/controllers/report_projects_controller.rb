class ReportProjectsController < ApplicationController
  include AuthenticatedSystem
  include ActionView::Helpers::NumberHelper
  include Ruport::Data
  layout "standard"
  #before_filter :find_project, :only => [ :show, :edit, :update, :destroy,:finance_summary,:customer_list,:edititems,:list_item_data ]
  #7before_filter :find_active_projects, :only => [ :active]
  before_filter :login_required
  require_role "admin"
  def index
    
    @year = params[:year]
    @year = Time.now.year if @year.nil?||@year.empty? 
    #:methods=>["total_report","iva_report","total_ivato_report"],
    respond_to do |format|
      format.html   {render :layout =>"standard" } # index.html.erb (no data required)
      
      format.odt{
        find_projects
        odt
      }
      
      format.ext_json {
        find_projects
        #,:include=>{:customer=>{:only=>"ragionesociale"}}
        render :json => @projects.to_ext_json(
                                           :include=>{
                                             :status=>{:only=>:status},
                                             :customer=>{:only=>:ragionesociale},
                                            },
                                            :methods=>[
                                                    "approved_pricings","euro_pricing_total",
                                                    "approved_invoices","euro_invoice_total"
                                            ]
        )  
        
      }
    end
  end
  
  def find_projects
    @projects = Project.find(:all,:conditions=>["year=#{params[:year]}"])
  end
  
end
