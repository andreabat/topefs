class ReportPricingsController < ApplicationController
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
      # find_pricings
        odt
      }
      
      format.ext_json {
        find_pricings
        #,:include=>{:customer=>{:only=>"ragionesociale"}}
        render :json => @pricings.to_ext_json(
                                        #
                                        :include=>{
                                             :project=>{:only=>:code,:methods=>[],:include=>{:customer=>{:only=>"ragionesociale"}}},
                                            },
                                            :methods=>["status","total","euro_total"]
                                            
        )  
        
      }
    end
  end
  
  
  
  
  def odt
    unless current_user.has_role?("admin")
      access_denied
    end
    path = File.join(RAILS_ROOT, 'doc','elenco_preventivi.ods');
    name = "elenco_preventivi.ods"
    outpath = File.join(RAILS_ROOT, "public",  "elenco_preventivi",name)
    table = Pricing.report_table(:all,
                              :include=>{
                                             :project=>{:only=>"code",:methods=>[],:include=>{:customer=>{:only=>"ragionesociale"}}},
                                            },
                                            :methods=>["status","total","euro_total","euro_discount"],
                              :conditions => build_query) 
                              #" #{(params[:approvati].nil?)?'':'approved=1 and'} year>=#{params['year']}")
    
    
    
    opts = {:precision=>4,:delimiter=>".",:separator=>","}
    table.sort_rows_by! ["year"],:order=>"descending"
    table.to_ods_template(   :template_file => path,
      :title=>"CRONOLOGICO PREVENTIVI #{params['year']}",
      :totalone=> number_to_currency(table.sigma("total"),opts),
      :output_file   =>outpath)
    #     @object.document=Document.new(:project_id=> @object.id, :doctype=>"timesheet",:user_id=>current_user.id)
    #     File.open(outpath)
    #  @object.save
    send_file(outpath,:filename=>name,:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
    
  end
#  def find_pricings
#    pagination_state = update_pagination_state_with_params!(:pricing)
#    all_opts = options_from_pagination_state(pagination_state).merge(options_from_search(:pricing))
#    all_opts[:conditions]=[]
#    cond  = "year=#{params[:year]}" #unless  params[:year].nil?
#    cond = cond + " and approved=#{params[:approvati]}" unless  params[:approvati].nil?
#    all_opts[:conditions] << cond
#    
#    puts "***************"
#    puts all_opts[:conditions]
#    
#    @count = Pricing.count(:all,all_opts)
#    puts "*****************+++"
#    @pricings = Pricing.find(:all,all_opts)
#  end
def find_pricings
    all_opts={:conditions => build_query }
    @count = Pricing.count(:all,all_opts)
    @pricings = Pricing.find(:all,all_opts)
end

  def build_query 
    
    #return if params[:query].nil?
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
                elsif (field=="approval_date")
                  oper = "between"
                  a = params[:query].split("/").reverse.join("-")
                   
                  value = " '#{a} 00:00:00' AND '#{a} 23:59:59' "
                else
                  value = "'%#{params[:query]}%'"
                end
                
                search_conditions << "#{field} #{oper} #{value}" unless value.nil?
      query = "(" << search_conditions.join(' OR ') << ") AND " unless params[:query].empty?
     end unless params[:query].nil?
     end
    query << " approved=#{params[:approvati]} AND" unless  params[:approvati].nil? or params[:approvati].empty?
    query << " year=#{params[:year]}" #unless  params[:year].nil?
    puts query
    query
  end
  
end
