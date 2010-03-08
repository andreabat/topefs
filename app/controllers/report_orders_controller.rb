class ReportOrdersController < ApplicationController
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
        find_orders
        odt
      }
      
      format.ext_json {
        find_orders
        render :json => @orders.to_ext_json(:include=>{
                                          :supplier=>{:only=>"ragionesociale"},
                                          :project=>{:only=>"code"}
                                            },
                                            :methods=>["total_report","iva_report","total_ivato_report"]
        )  
        
      }
    end
  end
  
  
  def calcolo_totale
    
    
    
    
  end
  
  def odt
    unless current_user.has_role?("admin")
      access_denied
    end
    path = File.join(RAILS_ROOT, 'doc','elenco_ordini.ods');
    name = "elenco_ordini.ods"
    outpath = File.join(RAILS_ROOT, "public",  "elenco_ordini",name)
    table = Order.report_table(:all,
                              :include=>{
                                          :supplier=>{:only=>"ragionesociale"},
                                          :project=>{:only=>"code"}
    },
                              :methods=>["total","total_ivato","valore_iva","total_report","iva_report","total_ivato_report"],
                              :conditions => "year>=#{params['year']} and deleted=0")
    
    
    
    opts = {:precision=>4,:delimiter=>".",:separator=>","}
    table.sort_rows_by! ["year"],:order=>"descending"
    table.to_ods_template(   :template_file => path,
      :title=>"CRONOLOGICO ORDINI A FORNITORI #{params['year']}",
      :totalone=> number_to_currency(table.sigma("total"),opts),
      :totalone_iva=> number_to_currency(table.sigma("valore_iva"),opts),
      :totalone_ivato=> number_to_currency(table.sigma("total_ivato"),opts),
      :output_file   =>outpath)
    #     @object.document=Document.new(:project_id=> @object.id, :doctype=>"timesheet",:user_id=>current_user.id)
    #     File.open(outpath)
    #  @object.save
    send_file(outpath,:filename=>name,:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
    
  end
  def find_orders
    pagination_state = update_pagination_state_with_params!(:order)
    all_opts = options_from_pagination_state(pagination_state).merge(options_from_search(:order))
    all_opts[:conditions]=[]
    #.merge({:conditions => "status_id=1"})
    #print (all_opts)
    all_opts[:conditions] << "deleted=0 and year=#{params[:year]}" #unless  params[:year].nil?
    
    
    puts all_opts[:conditions]
    #    @res = Order.find(:all,        
    #                           :conditions => "",
    #                          :order=>"id desc")
    @count = Order.count(:all,options_from_search(:order))
    @orders = Order.find(:all,all_opts)
  end
  
  
end
