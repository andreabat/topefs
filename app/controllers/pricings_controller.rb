#require "prawn"
#require "prawn/layout"
require "ruport"
require 'documatic'
include Ruport::Data

class PricingsController < ApplicationController
  layout "output"
  include AuthenticatedSystem
  include FileColumn 
   include ActionView::Helpers::NumberHelper
  
before_filter :login_required
  require_role ["admin","account"]
  
    def index
      @project = Project.find(params[:project_id])
    respond_to do |format|
      format.html   {render :layout =>"standard" } # index.html.erb (no data required)

      format.ext_json { 
          f = find_pricings
          render :json => f.to_ext_json(:class => :pricing, :count => @count,:include=>{
                                                                            :user=>{:only=>"login"},
                                                                            :project=>{:only=>"title"}
                                                                    }) 
        }
    end
  end
  
  def approve
     @object = Pricing.find(params[:id])
     @object.approved=true
     @object.approval_date=Time.now
     @object.save
     render :json => {:success=>true}
  end
  
  def show
    @object = Pricing.find(params[:id])
    @company =  @object.budget.project.company
    
    render  :action =>"default"
  end
  
  def edit
    @object = Pricing.find(params[:id])
    @object_scope="pricings"
    @company =  @object.project.company
    respond_to do |format|  
      format.html { render  :action =>"default",:layout =>"htmleditor" }
      format.xls  {excel}
      format.odt  {documatic}
      #format.pdf { render :layout=>false}
    end
  end
  
  def documatic
    
    path = File.join(RAILS_ROOT, 'doc','preventivo.odt');
    name = "preventivo_#{@object.code.gsub("/","_").rjust(8,"0")}.odt"
    #"
    outpath = File.join(RAILS_ROOT, "public",  "document",name)
    
    table = @object.pricingitems.report_table(:all,:methods=>["category_name","price_label","qty_label","totale"])
#    sorted_table = table.sort_rows_by(["category_name","display_order"], :order => :ascending)

    #table = @object.pricingitems.report_table(:all,:methods=>["category_name","price_label","qty_label","totale"])
    #table = @object.pricingitems.report_table(:all,:order=>"created_at",:methods=>["category_name","price_label","qty_label","totale"])
    #table.sort_rows_by!("display_order", :order => :ascending)
    table.sort_rows_by!(["category_name","projectitem_id"])
    data = Grouping.new(table,:by=>"category_name",:order => lambda { |x| x.to_s })
    
    #data = Group.new(:data=>sorted_table,:name=>"category_name")
    #data.sort_grouping_by!(:category_name)
    
    totale = @object.total
    
    totale = @object.total - @object.discount if @object.discount>0
    
    data.to_odt_template(   :template_file => path,
      :company=>@company,
      :date=>@object.created_at.l('%d/%m/%Y'),
      :customer=>@object.project.customer,
      :total=> (number_to_currency totale),
      :delivery=>@object.delivery,
      :sender=>@object.user.nominativo,
      :to=>@object.people,
      :payment=> @object.paymentmethod ? @object.paymentmethod.paymentmethod : "",
      :invoicing=>@object.invoicing ,
      :code=>"n.#{@object.code.rjust(8,"0")}",
      :discount=>@object.discount>0?(number_to_currency -@object.discount):"",
      :job=>"n.#{@object.project.code.rjust(8,"0")}",
      :subject=>@object.title,
      :output_file   =>outpath)
     @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"preventivo",:user_id=>current_user.id)
     @object.document.doc=File.open(outpath)
     @object.save
     send_file(outpath,:filename=>name,:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
  end
  
#  
  
  def showbyprojectitem
    @object = Pricingitem.find(:first,:conditions=>{:projectitem_id=>params[:id]})
    redirect_to(:controller => "documents", :action => "show", :id=>@object.pricing.document_id)
    
  end
  
  def create_document
    
    @object = Pricing.find(params[:id])
    @company =  @object.project.company 
    out = render_to_string :inline=>params[:html], :layout =>"output"
    #logger.debug out
    #create file
    path = File.join(RAILS_ROOT, 'public',  'document','preventivo');
    FileUtils.mkdir path unless File.exists?(path)
    filename = File.join(path,"preventivo_#{@object.code.gsub('/','-')}_#{@object.id}.html" );
    a=File.open(filename, 'w') do |f|
      f.write(out)
    end
    

    @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"preventivo",:user_id=>current_user.id)
    
    @object.document.doc=File.open(filename)
    @object.save
    render :json => {:success => true,:doctype=>"preventivo",:filename => File.basename(filename)}.to_json
  end
  
  def create
#    template=params[:template]
#    template = "default" unless template
#    logger.debug "Il template selezionato e' #{template}"
    #template serve per la visualizzazione
    #creo prima il record prev
     @object = Pricing.new(params[:pricing])
     #logger.debug "preventivo  e' #{@object.title}"
     @object.user_id = current_user.id
     
     
     
     if @object.save
       #è necessario copiare da budgeitems in previtems
       index=0   
       params[:projectitem].each{|key,value|   
                    bi = Projectitem.find(value)
                    oi = Pricingitem.new( 
                        :quantity=>bi.quantity,
                        :price=>bi.price,
                        :description=>bi.description,
                        :projectitem_id=>bi.id,
                        :category_id=>bi.category_id,
                        :display_order=>index
                     )
                      @object.pricingitems << oi
                      index=index+1
       }
       @company =  @object.project.company
       # se qui invece creassi il documento ?
    
       #out = render_to_string :action =>template
       #logger.debug "ho genereato #{{:success => true,:id=>@object.id,:html=>out}.to_json}"
       render :json => {:success => true,:id=>@object.id}.to_json
    else
      render :json => {:success => false}.to_json
   end
  end
  
 def pricing_by_item
    
    if !params[:dna] then
      f =  Pricing.find(:first,:include=>[:pricingitems],
            :conditions=>['pricingitems.projectitem_id=? and approved=true',
            params[:id]]) 
      redirect_to :action=> "index", :project_id=>f.project_id, :pricingid=>f.id
    else
      f =  Pricing.find(:first,:include=>[:pricingitems],
            :conditions=>['pricingitems.projectitem_id=? and approved=false',
            params[:id]]) if params[:dna]
      redirect_to :action=> "index", :project_id=>f.project_id,:itemid=>params[:id], :pricing_list => true
    end
    
    
 end 

 # DELETE /pricings/1
  def destroy
    @object = Pricing.find(params[:id])
    un_deletable = @object.un_deletable
    @object.destroy if !un_deletable
  
    respond_to do |format|
      format.ext_json   {render :json=>{:success => false,:errors=>true,:msg=>"Impossibile cancellare un preventivo.Soltanto un preventivo non approvato può essere cancellato." }} if un_deletable
      format.ext_json   {render :json=>{:success => true,:msg=>'OK' } }  if !un_deletable
  end
end

   
  
 def find_pricings
      if params[:pricing_list] then
             
            @pricings =  Pricing.find(:first,:include=>[:pricingitems],
            :conditions=>['pricingitems.projectitem_id=? and approved=false',
            params[:itemid]])
            @count = @pricings.length
            return 
      end
   
      pagination_state = update_pagination_state_with_params!(:pricing)
      condition = {:conditions => "project_id="+params[:project_id]} if params[:project_id]
      condition = {:conditions => "id=" + params[:pricingid]} if params[:pricingid]
     # condition = {:conditions => "budget_id="+params[:budget_id]} if params[:budget_id]
      @count = Pricing.count(:all,condition)
      @pricings= Pricing.find(:all,options_from_pagination_state(pagination_state).merge(condition))
  end
  
end


#def excel
#    
#    path = File.join(RAILS_ROOT, 'doc','preventivo.xls');
#
#     book = Spreadsheet.open path
#     sheet1 = book.worksheet 0
#     sheet1.row(1)[5]=@company.ragionesociale
#     sheet1.row(2)[7]=@company.indirizzo
#     sheet1.row(3)[7]="#{@company.cap} #{@company.comune} - Italia"
#     sheet1.row(4)[7]="T. #{@company.telefono}"
#     sheet1.row(5)[7]="F. #{@company.fax}"
#     sheet1.row(6)[7]="P.IVA #{@company.partitaiva}"
#     sheet1.row(7)[7]=@company.web
#     
#     
#     
#     sheet1.row(9)[2]=@object.created_at.l('%d/%m/%Y')
#     sheet1.row(10)[2]="n.#{@object.code.rjust(8,"0")}"
#     sheet1.row(10)[4]=@object.project.customer.ragionesociale
#     sheet1.row(11)[2]="n.#{@object.project.code.rjust(8,"0")}"
#     sheet1.row(13)[2]=@object.user.nominativo
#     sheet1.row(13)[5]=@object.people
#     sheet1.row(15)[2]=@object.title
#     start_row = 20
#     current_cat = 0
#     word_limit = 63
#     
#     @object.pricingitems.find(:all,:order=>"category_id desc").each do |e| 
#       
#       if e.category!=nil && (current_cat!=e.category_id)  
#          start_row+=1
#          sheet1.row(start_row)[1]=e.category.name.upcase   
#          start_row+=1
#          current_cat=e.category_id
#       end
#       desc = "- #{e.description}"
#
#       end_index = 0
#       while (end_index!=nil) do
#         if (desc.length<=word_limit) then
#            end_index = nil
#          else
#             end_index = desc.rindex("\s",word_limit)
#           end
#         
#         if (end_index==nil) then
#            piece =desc[0..desc.length-1] 
#         else 
#           piece=desc[0..end_index]
#           desc =desc[end_index+1..desc.length-1] 
#         end
#          sheet1.row(start_row)[1]=piece
#          start_row+=1 unless !end_index
#       end
#       
##       sheet1.row(start_row)[1]= "- #{e.description}"
#       sheet1.row(start_row)[5]= e.quantity  unless !e.quantity
#       sheet1.row(start_row)[6]= number_to_currency e.price  unless !e.price
#       logger.info("Il valore di price " + e.price.to_s)
#       sheet1.row(start_row)[7]= number_to_currency(e.price * (e.quantity ? e.quantity : 1))
#       start_row+=1
#     end
#     if @object.discount>0
#       sheet1.row(start_row)[1]="Sconto"
#       sheet1.row(start_row)[7]= number_to_currency -@object.discount
#     end
#     #range valido 21 -41 se vado oltre 40 devo aggiungere righe con uno stratagemma.
#     
#     
##     mr = sheet1.row(1000)
##
##     sheet1.rows.insert(6,mr)
##     sheet1.updated_from(6)
##     sheet1.row(6)[1]= "@object.total"
#     #Parte per l'inserimento del totale
#     totale = @object.total
#     totale = @object.total - @object.discount if @object.discount>0
#     sheet1.row(42)[7]= number_to_currency totale
#     sheet1.row(45)[2]= @object.delivery
#     sheet1.row(46)[2]= @object.paymentmethod.paymentmethod unless !@object.paymentmethod
#     sheet1.row(47)[2]= @object.invoicing unless !@object.invoicing
#     sheet1.row(54)[6]= @company.ragionesociale
#     name = "preventivo_#{@object.code.gsub('/','_').rjust(8,'0')}.xls"
#     path =File.join(RAILS_ROOT, 'public',  'document',name);
#     book.write path
#     
#     @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"preventivo",:user_id=>current_user.id)
#    
#     @object.document.doc=File.open(path)
#     @object.save
#     
#     send_file(path,:filename=>name,:type=> "application/excel", :disposition => 'inline')
#  end
