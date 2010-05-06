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
       # find_projects
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
                                                    "approved_invoices","euro_invoice_total",
                                                    "euro_costs_approved_invoices_total",
                                                    "euro_mol","perc_mol"
                                            ]
        )  
        
      }
    end
  end
  def odt
    unless current_user.has_role?("admin")
      access_denied
    end
    path = File.join(RAILS_ROOT, 'doc','elenco_commesse.ods');
    name = "elenco_commesse.ods"
    outpath = File.join(RAILS_ROOT, "public",  "elenco_commesse",name)
    table = Project.report_table(:all,
                                :include=>{
                                          :status=>{:only=>"status"},
                                          :customer=>{:only=>"ragionesociale"}},
                              :methods=>["approved_pricings_text","euro_pricing_total",
                                                    "pricing_total","approved_invoices_text",
                                                    "invoice_total","euro_invoice_total",
                                                    "costs_approved_invoices_total","euro_costs_approved_invoices_total",
                                                    "mol",
                                                    "euro_mol","perc_mol"],
                              :conditions => build_query)
    
    
    
    opts = {:precision=>4,:delimiter=>".",:separator=>","}
    table.sort_rows_by! ["year"],:order=>"descending"
    table.to_ods_template(   :template_file => path,
      :title=>"LIBRO COMMESSE #{params['year']}",
      :totalone_preventivi=> number_to_currency(table.sigma("pricing_total"),opts),
      :totalone_fatture=> number_to_currency(table.sigma("invoice_total"),opts),
      :totalone_mol=> number_to_currency(table.sigma("mol"),opts),
      :totalone_costi=> number_to_currency(table.sigma("costs_approved_invoices_total"),opts),
       
      :output_file   =>outpath)
    #     @object.document=Document.new(:project_id=> @object.id, :doctype=>"timesheet",:user_id=>current_user.id)
    #     File.open(outpath)
    #  @object.save
    send_file(outpath,:filename=>name,:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
    
  end
  def find_projects
    
     all_opts={:conditions => build_query }
    @count = Project.count(:all,all_opts)
    @projects = Project.find(:all,all_opts)
    
  #  @projects = Project.find(:all,:conditions=>["year=#{params[:year]}"])
  end
  def build_query 
    
   # return if params[:query].nil?
    search_conditions = [] 
    query = ""
    unless params[:fields].nil?
        ActiveSupport::JSON::decode(params[:fields]).each do |field|
                    field.sub!(/(\A[^\[]*)\[([^\]]*)\]/,'\2') # fields may be passed as "object[attr]"
                    value = nil
                    oper = "LIKE"
                     if (field=="customer")
                      field='customer_id'
                      oper = "="
                      cs = Customer.find(:first,:conditions=>"ragionesociale LIKE '%#{params[:query]}%'")
                      unless cs.nil?
                        value = cs.id 
                      end
                    elsif (field=="job")
                      field='code'
                      oper = "="
                      code = params[:query]
                      code = "#{code}/#{params[:year]}" unless (code.include?"/#{params[:year]}")
                      #pro = Project.find(:first,:conditions=>{:code=>code})
                      #value = "#{pro.id}" unless pro.nil?
                      value = code
                    else
                      value = "'%#{params[:query]}%'"
                    end
                    
                    search_conditions << "#{field} #{oper} #{value}" unless value.nil?
        
        
                    query = "(" << search_conditions.join(' OR ') << ") AND " unless search_conditions.size==0
        end unless params[:query].nil?  or params[:query].empty? or params[:fields].empty?
    end
    query << "  year=#{params[:year]}" #unless  params[:year].nil?
    query
  end
end
