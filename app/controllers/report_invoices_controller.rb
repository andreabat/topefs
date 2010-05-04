class ReportInvoicesController < ApplicationController
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
        #find_invoices
        odt
      }
      
      format.ext_json {
        find_invoices
        render :json => @invoices.to_ext_json(:include=>{
                                          :paymentmethod=>{:only=>"paymentmethod"},
                                          :project=>{:only=>"code",:methods=>[]}
                                            },
                                          :methods=>["status","euro_total","euro_iva","euro_imponibile","total","iva","imponibile","customer","expiration"]
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
    path = File.join(RAILS_ROOT, 'doc','elenco_fatture.ods');
    name = "elenco_fatture.ods"
    outpath = File.join(RAILS_ROOT, "public",  "elenco_fatture",name)
    table = Invoice.report_table(:all,
                              :include=>{
                                          :project=>{:only=>"code"},
                                          :paymentmethod=>{:only=>"paymentmethod"}
                              },
                              :methods=>["status","euro_total","euro_iva","euro_imponibile","total","iva","imponibile","expires","expired","customer","expiration"],
                              :conditions => build_query)
    
    
    
    opts = {:precision=>4,:delimiter=>".",:separator=>","}
    table.sort_rows_by! ["year"],:order=>"descending"
    table.to_ods_template(   :template_file => path,
      :title=>"CRONOLOGICO FATTURE #{params['year']}",
      :totalone_imponibile=> number_to_currency(table.sigma("imponibile"),opts),
      :totalone_iva=> number_to_currency(table.sigma("iva"),opts),
      :totalone=> number_to_currency(table.sigma("total"),opts),
      :output_file   =>outpath)
    #     @object.document=Document.new(:project_id=> @object.id, :doctype=>"timesheet",:user_id=>current_user.id)
    #     File.open(outpath)
    #  @object.save
    send_file(outpath,:filename=>name,:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
    
  end
#  def find_invoices
#    pagination_state = update_pagination_state_with_params!(:invoice)
#    all_opts = options_from_pagination_state(pagination_state)
#    #all_opts[:limit]=9219319239123129
#    #.merge(options_from_search(:invoice))
#   # all_opts = options_from_search(:invoice)
#   
#    all_opts[:conditions]=[]
#    #.merge({:conditions => "status_id=1"})
#    #print (all_opts)
#    
#    all_opts[:conditions] << "deleted=0 and year=#{params[:year]}" #unless  params[:year].nil?
#    #all_opts[:order]= "#{params[:sort]} #{params[:dir]}"
#    #all_opts[:order]=params[:sort]
#    
#    
#    #    @res = Order.find(:all,        
#    #                           :conditions => "",
#    #                          :order=>"id desc")
#    @count = Invoice.count(:all,all_opts)
#    @invoices = Invoice.find(:all,all_opts)
#    puts all_opts[:order]
#  end
def find_invoices
    all_opts={:conditions => build_query }
    @count = Invoice.count(:all,all_opts)
    @invoices = Invoice.find(:all,all_opts)
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
                      field='project_id'
                      oper = " in ("
                      cs = Customer.find(:first,:conditions=>"ragionesociale LIKE '%#{params[:query]}%'")
                      unless cs.nil?
                        valid_ids=cs.projects.reject{|p|p.year!=params[:year]}.map{|p|p.id}
                        #print valid_ids.join(",")
                        value = valid_ids.join(",") + ")" 
                      end
                    elsif (field=="job")
                      field='project_id'
                      oper = "="
                      code = params[:query]
                      code = "#{code}/#{params[:year]}" unless (code.include?"/#{params[:year]}")
                      pro = Project.find(:first,:conditions=>{:code=>code})
                      value = "#{pro.id}" unless pro.nil?
                    elsif (field=="created_at")
                      oper = "between"
                      a = params[:query].split("/").reverse.join("-")
                       
                      value = " '#{a} 00:00:00' AND '#{a} 23:59:59' "
                    else
                      value = "'%#{params[:query]}%'"
                    end
                    
                    search_conditions << "#{field} #{oper} #{value}" unless value.nil?
        
        
          query = "(" << search_conditions.join(' OR ') << ") AND " unless params[:query].empty?
          end unless params[:query].nil? or params[:fields].empty?
    end
    query << " deleted=0 and year=#{params[:year]}" #unless  params[:year].nil?
     puts query
    query
  end
  
end
