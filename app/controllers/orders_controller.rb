require "ruport"
require 'documatic'


class OrdersController < ApplicationController
  layout "output"
  include AuthenticatedSystem
  include FileColumn 
  include ActionView::Helpers::NumberHelper
  include Ruport::Data

  before_filter :login_required

  require_role "account"
  require_role "admin",:for=>[:destroy,:payed,:not_payed,:edit,:create_document,:create,:update]
  
  def index
    @project = Project.find(params[:project_id])
    respond_to do |format|
      format.html   {render :layout =>"standard" } # index.html.erb (no data required)

      format.ext_json { 
          f = find_orders
          render :json => f.to_ext_json(:class => :order,:methods=>[:total,:total_ivato], :count => @count,:include=>{
                                                                            :user=>{:only=>"login"},
                                                                            :project=>{:only=>"title"}
                                                                    }) 
        }
    end
  end
  
    def expired
      find_expired
      render :json => @orders.to_ext_json(:class=>:order,:count => @count,:methods=>[:code,:total_ivato],:include=>{:project=>{:only=>"title"},:supplier=>{:only=>["ragionesociale","id"]}}) 
  end
  
  def show
    @object = Order.find(params[:id])
    @company =  @object.project.company
    render  :action =>"default"
  end
  
  def edit
    @object_scope="orders"
    @object = Order.find(params[:id])
    @company =  @object.project.company
      respond_to do |format|  
      format.html { render  :action =>"default",:layout =>"htmleditor" }
      format.xls  {excel}
      format.odt  {odt}
      #format.pdf { render :layout=>false}
    end
  end
  
  def update
     @order=Order.find(params[:id])
      respond_to do |format|
      if @order.update_attributes(params[:order])
        format.ext_json { render :json => @order.to_ext_json(:success => true) }
      else
        format.ext_json { render :json => @order.to_ext_json(:success => false) }
      end
    end
  end
  
  def create_document
    @object = Order.find(params[:id])
    @company =  @object.project.company 
    out = render_to_string :inline=>params[:html], :layout =>"output"
    #create file
    path = File.join(RAILS_ROOT, 'public',  'document','ordine');
    FileUtils.mkdir path unless File.exists?(path)
    filename = File.join(path,"ordine_#{@object.id }.html" );
    a=File.open(filename, 'w') do |f|
      f.write(out)
    end
    

    @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"ordine",:user_id=>current_user.id)
    
    @object.document.doc=File.open(filename)
    @object.save
    render :json => {:success => true,:doctype=>"ordine",:filename => File.basename(filename)}.to_json
  end
  
  def create
#    template=params[:template]
#    template = "default" unless template
#    logger.debug "Il template selezionato e' #{template}"
    #template serve per la visualizzazione
    #creo prima il record order
     @object = Order.new(params[:order])
#     logger.debug "order e' #{@object.title}"
     @object.user_id = current_user.id
     @object.deleted=false
     
     if @object.save
       #è necessario copiare da budgeitems in orderitems
       params[:projectitem].each{|key,value|   
                    bi = Projectitem.find(value)
                    oi = Orderitem.new( 
                        :quantity=>bi.quantity,
                        :cost=>bi.cost,
                        :description=>bi.description,
                        :projectitem_id=>bi.id 
                     )
                      @object.orderitems << oi 
                      
                      
                      
       }
       
       @company =  @object.project.company
#       out = render_to_string :action =>template
#       logger.debug "ho genereato #{{:success => true,:id=>@object.id,:html=>out}.to_json}"
       render :json => {:success => true,:id=>@object.id}.to_json
    else
      render :json => {:success => false}.to_json
   end
  end

# DELETE /orders/1
  def destroy
    @object = Order.find(params[:id])
    un_deletable = @object.un_deletable
    @object.destroy if !un_deletable
    
  
    respond_to do |format|
      format.ext_json   {render :json=>{:success => false,:errors=>true,:msg=>"Impossibile cancellare un ordine.Soltanto l'ultimo ordine generato può essere cancellato." }} if un_deletable
      format.ext_json   {render :json=>{:success => true,:msg=>'OK' } }  if !un_deletable
  end
end

 def payed
    d =Date.parse(params[:date])
    i = Order.find(params[:id])
    i.payed_invoice=1
    i.payed_invoice_date=d
    i.save
  end
  
  def not_payed
    i = Order.find(params[:id])
    i.payed_invoice=0
    i.save
  end
 
 def order_by_item
    f = Orderitem.find_by_projectitem_id(params[:id]).order
     redirect_to :action=> "index", :project_id=>f.project_id, :orderid=>f.id
 end
 
 
 def elenco_generale_odt
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
                              :methods=>["total_report","iva_report","total_ivato_report"],
                              :conditions => "year>=#{params['year']} and deleted=0")
    table.sort_rows_by! ["year"],:order=>"descending"
    table.to_ods_template(   :template_file => path,
      :title=>"CRONOLOGICO ORDINI A FORNITORI #{params['year']}",
      :output_file   =>outpath)
#     @object.document=Document.new(:project_id=> @object.id, :doctype=>"timesheet",:user_id=>current_user.id)
#     File.open(outpath)
   #  @object.save
     send_file(outpath,:filename=>name,:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
  end

protected
def odt
    path = File.join(RAILS_ROOT, 'doc','ordine.odt');
    name = "ordine_#{@object.code.gsub('/','_').rjust(8,'0')}.odt"
    #"
    outpath = File.join(RAILS_ROOT, 'public',  'document',name)
    data = @object.orderitems.report_table(:all,:methods=>["line_description","totale","category_name"])
    totale = @object.total
    
    @object.vat
    
    
#    data.sort_rows_by!("categoty_name")
    data.sort_rows_by!(["category_name","projectitem_id"])
 
    #puts @company.cap_comune_nazione
    data.to_odt_template(   :template_file => path,
      :title=>"ORDINE DI LAVORO #{@object.created_at.year}",
      :company=>@company,
      :order_date=>@object.created_at.l('%d/%m/%Y'),
      :supplier=>@object.supplier,
      :total=> (number_to_currency totale),
      :discount=>(@object.discount.nil?||@object.discount==0)?nil: (number_to_currency @object.discount),
      :delivery=>@object.delivery,
      :people=>@object.people,
      :payment=> @object.paymentmethod ? @object.paymentmethod.paymentmethod : "",
      :code=>"#{@object.code.rjust(8,"0")}",
      :vat=>(@object.vat!=nil)?("#{@object.vat} %"):"",
      :job=>"#{@object.project.code.rjust(8,"0")}",
      :subject=>@object.title,
      :output_file   =>outpath)
                      
       
     @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"ordine",:user_id=>current_user.id)
     @object.document.doc=File.open(outpath)
     @object.save
     
     send_file(outpath,:filename=>name,:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
end


def excel
     path = File.join(RAILS_ROOT, 'doc','ordine.xls');
     book = Spreadsheet.open path
     sheet1 = book.worksheet 0
     sheet1.row(2)[8]=@company.ragionesociale
     sheet1.row(3)[8]=@company.indirizzo
     sheet1.row(4)[8]="#{@company.cap} #{@company.comune} - Italia"
     sheet1.row(5)[8]="T. #{@company.telefono}"
     sheet1.row(6)[8]="F. #{@company.fax}"
     sheet1.row(7)[8]="P.IVA #{@company.partitaiva}"
     sheet1.row(8)[8]=@company.web
     sheet1.row(9)[1]="ORDINE DI LAVORO #{@object.created_at.year}" 
     sheet1.row(11)[6]=@object.supplier.ragionesociale
     sheet1.row(12)[6]=@object.supplier.indirizzo
     sheet1.row(13)[6]="#{@object.supplier.cap} #{@object.supplier.comune} #{@object.supplier.prov}"
     sheet1.row(14)[6]="c.a. #{@object.people}"
     sheet1.row(19)[1]=@object.created_at.l("%d-%m-%Y")
     sheet1.row(19)[2]="#{@object.code.rjust(8,"0")}"
     sheet1.row(19)[3]="#{@object.project.code.rjust(8,"0")}"
     sheet1.row(19)[4]=@object.title
     
     
     start_row = 21
     word_limit = 73
     
     @object.orderitems.each do |e| 
       desc = ""
       desc = "n. #{number_with_precision(e.quantity,0)}  " unless !e.quantity
       desc += e.description
       desc += "  #{number_to_currency(e.cost)}/Cad." unless !e.quantity
       #sheet1.row(start_row)[1]=desc
        end_index = 0
       while (end_index!=nil) do
         if (desc.length<=word_limit-1) then
            end_index = nil
          else
             end_index = desc.rindex("\s",word_limit)
           end
         
         if (end_index==nil) then
            piece =desc[0..desc.length-1] 
         else 
           piece=desc[0..end_index]
           desc =desc[end_index+1..desc.length-1] 
         end
          sheet1.row(start_row)[1]=piece
          start_row+=1 unless !end_index
       end
      

       sheet1.row(start_row)[8]=e.cost * (e.quantity ? e.quantity : 1)
       start_row+=2
       end
     
     #Parte per l'inserimento del totale
     sheet1.row(49)[8]= @object.total
     sheet1.row(52)[2]= @object.delivery
     sheet1.row(51)[2]= @object.paymentmethod.paymentmethod unless !@object.paymentmethod
     sheet1.row(53)[2]= "#{@object.vat} %" unless !@object.vat

     name = "ordine_#{@object.code.gsub('/','_').rjust(8,'0')}.xls"
     path =File.join(RAILS_ROOT, 'public',  'document',name);
     book.write path
     
     @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"ordine",:user_id=>current_user.id)
    
     @object.document.doc=File.open(path)
     @object.save
     
     send_file(path,:filename=>name,:type=> "application/excel", :disposition => 'inline')
  end

def find_expired
      @orders = Order.find(:all,:conditions=>"payed_invoice=0 and received_invoice=1")
      @orders.sort!{|a,b|b.expires_invoice<=>a.expires_invoice}
      @count = @orders.size
end



def find_orders
      pagination_state = update_pagination_state_with_params!(:order)
      condition = {:conditions => "project_id="+params[:project_id]} if params[:project_id]
      condition = {:conditions => "id="+params[:orderid]} if params[:orderid]
      @count = Order.count(:all,condition)
      @orders= Order.find(:all,options_from_pagination_state(pagination_state).merge(condition))
      
  end  
end
