require "ruport"
require 'documatic'

class InvoicesController < ApplicationController
  before_filter :login_required
  layout "output"
  include AuthenticatedSystem
  include FileColumn
  include ActionView::Helpers::NumberHelper
  include Ruport::Data
  require_role "account"
  require_role "admin",:for=>[:destroy,:payed,:create_from_pricing,:new_from_pricing,:edit,:create_document,:create,:update]
  
  def index
    @project=   Project.find(  params[:project_id] ) if     params[:project_id] 
    
    respond_to do |format|
      format.html   {render :layout =>"standard" } # index.html.erb (no data required)
      
      format.ext_json { 
        f = find_invoices
        render :json => f.to_ext_json(:class => :invoice, :count => @count,
                                                        :methods=>[:expires,:expired],
                                                        :include=>{
                                                                            :user=>{:only=>"login"},
                                                                            :project=>{:only=>"title"}
                                                                    }) 
      }
    end
  end
  
  def payed
    i = Invoice.find(params[:id])
    i.payed=1
    i.payed_date=Date.parse(params[:date])
    i.save
    render :json => {:success=>true}
  end
  
  def not_payed
    i = Invoice.find(params[:id])
    i.payed=0
    i.payed_date=nil
    i.save
    render :json => {:success=>true}
  end
  
  def expired
      find_expired
      render :json => @invoices.to_ext_json(:class=>:invoice,:count => @count,:methods=>[:expires,:expired,:customer],:include=>{:project=>{:only=>"title"}}) 
  end
   def showbyprojectitem
    @object = Invoiceitem.find(:first,:conditions=>{:projectitem_id=>params[:id]})
    redirect_to(:controller => "documents", :action => "show", :id=>@object.invoice.document_id)

    
  end
  def new_from_pricing
    respond_to do |format|
      format.html   {render :layout =>"standard" } 
      
      format.ext_json { 
        
        #             mi serve una struttura del genere
        #                                         { bank:'<%=@project.customer.coordinatebancarie%>',
        #                                          title :'<%=@project.title%>'}
        #          
        
        p = Project.find(  params[:project_id] )
        render :json => {:bank=>p.customer.coordinatebancarie,:title=>p.title }.to_json
        
      }
    end
  end
  
  def create_from_pricing

    @object = Invoice.new(params[:invoice])
    pricing = Pricing.find(params[:id])
   # @object.budget_id=pricing.budget_id
    @object.pricing_id=pricing.id
    @object.user_id = current_user.id
    if @object.save
      #è necessario copiare da budgeitems in previtems
      pricing.pricingitems.each{|bi|  
        oi = Invoiceitem.new( 
                             :quantity=>bi.quantity,
                             :price=>bi.price,
                             :description=>bi.description,
                             :projectitem_id=>bi.projectitem_id,
                             :category_id=>bi.category_id
        )
        logger.debug("will create new invoiceitem " + oi.to_json)
        @object.invoiceitems<< oi
       }
       render :json => {:success => true,:id=>@object.id}.to_json
    else
      render :json => {:success => false}.to_json
   end
    
    
  end
  
  def show
    @object = Invoice.find(params[:id])
    @company =  @object.project.company
    render  :action =>"default"
  end
  
  def edit
    @object = Invoice.find(params[:id])
    @object_scope="invoices"
    @company =  @object.project.company
      respond_to do |format|  
      format.html { render  :action =>"default",:layout =>"htmleditor" }
      format.xls  {excel}
      format.odt  {odt}
      #format.pdf { render :layout=>false}
    end
  end
  
  def create_document
     
    @object = Invoice.find(params[:id])
    @company =  @object.project.company 
    out = render_to_string :inline=>params[:html], :layout =>"output"
    logger.debug out
    #create file
    path = File.join(RAILS_ROOT, 'public',  'document','fattura');
    FileUtils.mkdir path unless File.exists?(path)
    filename = File.join(path,"fattura_#{@object.code.gsub('/','-')}_#{@object.id}.html" );
    a=File.open(filename, 'w') do |f|
      f.write(out)
    end
    

    @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"fattura",:user_id=>current_user.id)
    
    @object.document.doc=File.open(filename)
    @object.save
    render :json => {:success => true,:doctype=>"fattura",:filename => File.basename(filename)}.to_json
  end
  
  def create
   
    #template serve per la visualizzazione
    #creo prima il record prev
     @object = Invoice.new(params[:invoice])
     
     @object.user_id = current_user.id
     
     
     if @object.save
       #è necessario copiare da budgeitems in previtems
       params[:projectitem].each{|key,value|   
                    bi = Projectitem.find(value)
                    oi = Invoiceitem.new( 
                        :quantity=>bi.quantity,
                        :price=>bi.price,
                        :description=>bi.description,
                        :projectitem_id=>bi.id,
                        :category_id=>bi.category_id
                     )
                      @object.invoiceitems<< oi
       }
       @company =  @object.project.company
      # out = render_to_string :action =>template
#       logger.debug "ho genereato #{{:success => true,:id=>@object.id,:html=>out}.to_json}"
       render :json => {:success => true,:id=>@object.id,:code=>@object.code}.to_json
    else
      render :json => {:success => false}.to_json
   end
  end
  
# DELETE /invoices/1
  def destroy
    @object = Invoice.find(params[:id])
    un_deletable = @object.un_deletable
    @object.destroy if !un_deletable
    print "OK"
  
    respond_to do |format|
      format.ext_json   {render :json=>{:success => false,:errors=>true,:msg=>"Impossibile cancellare una fattura.Soltanto l'ultima fattura generata può essere cancellata." }} if un_deletable
      format.ext_json   {render :json=>{:success => true,:msg=>'OK'} }  if !un_deletable
      end
end  

 def invoice_by_item
     f = Invoiceitem.find_by_projectitem_id(params[:id]).invoice
     redirect_to :action=> "index", :project_id=>f.project_id, :invoiceid=>f.id
 end 
protected
def odt
    path = File.join(RAILS_ROOT, 'doc','fattura.odt');
    name = "fattura_#{@object.code.gsub('/','_').rjust(8,'0')}.odt"
    outpath = File.join(RAILS_ROOT, 'public',  'document',name)
    data = @object.invoiceitems.report_table(:all,:methods=>["line_description","totale","category_name"])
    totale = @object.total
    cf = (@object.project.customer.codicefiscale.nil?||@object.project.customer.codicefiscale.empty?) ? @object.project.customer.partitaiva : @object.project.customer.codicefiscale
    order = ""
    order = "RIFERIMENTO NS PREVENTIVO N. #{@object.pricing.code.rjust(8,"0")} DEL #{@object.pricing.created_at.l("%d-%m-%Y")}" if @object.pricing
    data.sort_rows_by!(["category_name","projectitem_id"])
 #   data = Grouping.new(table,:by=>"category_name",:order => lambda { |x| x.to_s })
#    puts table.as(:text)
    data.to_odt_template(   :template_file => path,
      :company=>@company,
      :invoice_date=>@object.created_at.l('%d/%m/%Y'),
      :cf=>"C.F. #{cf} - P.IVA #{@object.project.customer.partitaiva}",
      :order=>order,
      :people=>"c.a. #{@object.people}",
      :customer=>@object.project.customer,
      :total=> (number_to_currency totale),
      :imponibile=> (number_to_currency @object.imponibile),
      :delivery=>@object.delivery,
      :bank=> @object.bank,
      :payment=> @object.paymentmethod ? @object.paymentmethod.paymentmethod : "",
      :code=>"#{@object.code.rjust(8,"0")}",
      :iva=>number_to_currency(@object.iva),
      :job=>"#{@object.project.code.rjust(8,"0")}",
      :subject=>@object.title,
      :output_file=>outpath)
                      
       
     @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"fattura",:user_id=>current_user.id)
     @object.document.doc=File.open(outpath)
     @object.save
     
     send_file(outpath,:filename=>name,:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
end

def excel

     path = File.join(RAILS_ROOT, 'doc','fattura.xls');
     book = Spreadsheet.open path
     sheet1 = book.worksheet 0
     sheet1.row(2)[8]=@company.ragionesociale
     sheet1.row(61)[1]=@company.ragionesociale
     
     sheet1.row(3)[8]=@company.indirizzo
     sheet1.row(4)[8]="#{@company.cap} #{@company.comune} - Italia"
     sheet1.row(5)[8]="T. #{@company.telefono}"
     sheet1.row(6)[8]="F. #{@company.fax}"
     sheet1.row(7)[8]="P.IVA #{@company.partitaiva}"
     sheet1.row(8)[8]=@company.web
     
    
     sheet1.row(8)[1]=@object.project.customer.ragionesociale
     sheet1.row(9)[1]=@object.project.customer.indirizzo
     sheet1.row(10)[1]="#{@object.project.customer.cap} #{@object.project.customer.comune} #{@object.project.customer.prov}"
     cf = (@object.project.customer.codicefiscale.nil?||@object.project.customer.codicefiscale.empty?) ? @object.project.customer.partitaiva : @object.project.customer.codicefiscale
     sheet1.row(11)[1]="C.F. #{cf} - P.IVA #{@object.project.customer.partitaiva}"
     sheet1.row(12)[1]="c.a. #{@object.people}"



     sheet1.row(17)[1]= @object.created_at.l("%d-%m-%Y")
     sheet1.row(17)[2]= "#{@object.code.rjust(8,"0")}"
     sheet1.row(17)[3]= "#{@object.project.code.rjust(8,"0")}"
     sheet1.row(17)[4]= @object.title
     sheet1.row(19)[1]= @object.paymentmethod.paymentmethod unless !@object.paymentmethod
     sheet1.row(19)[2]= @object.delivery
     sheet1.row(19)[4]= @object.bank
     
     
     
     start_row = 22
     word_limit = 71
     sheet1.row(start_row)[1]= "RIFERIMENTO NS PREVENTIVO N. #{@object.pricing.code.rjust(8,"0")} DEL #{@object.pricing.created_at.l("%d-%m-%Y")}" if @object.pricing
     start_row+=2 if @object.pricing
     
     
     @object.invoiceitems.each do |e| 
       desc = ""
       desc = "N. #{number_with_precision(e.quantity,0)}  " unless !e.quantity
       desc += e.description
#       desc += "  #{number_to_currency(e.cost)}/Cad." unless !e.quantity
       #sheet1.row(start_row)[1]=desc
        end_index = 0
       while (end_index!=nil) do
         if (desc.length<=word_limit) then
            end_index = nil
          else
             end_index = desc.rindex("\s",word_limit-1)
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
      

       sheet1.row(start_row)[8]=e.price * (e.quantity ? e.quantity : 1)
       start_row+=2
       end
     
     #Parte per l'inserimento del totale
      
      
      sheet1.row(61)[8]= number_to_currency @object.imponibile
      sheet1.row(62)[8]= number_to_currency @object.iva
      sheet1.row(63)[8]= number_to_currency @object.total
      
#     sheet1.row(51)[2]= @object.paymentmethod.paymentmethod unless !@object.paymentmethod
#     sheet1.row(53)[2]= "#{@object.vat} %" unless !@object.vat

     name = "fattura_#{@object.code.gsub('/','_').rjust(8,'0')}.xls"
     path =File.join(RAILS_ROOT, 'public',  'document',name);
     book.write path
     
     @object.document=Document.new(:project_id=> @object.project_id, :doctype=>"fattura",:user_id=>current_user.id)
    
     @object.document.doc=File.open(path)
     @object.save
     
     send_file(path,:filename=>name,:type=> "application/excel", :disposition => 'inline')
  end
def find_expired
      @invoices = Invoice.find(:all,:conditions=>{ :payed=>0,:deleted=>0})
#       @invoices.reject!{|i|
#            i.expires > (Date.today+5)
#          }
          @invoices.sort!{|a,b|b.expires<=>a.expires}
      @count = @invoices.size
end
  
 def find_invoices
      pagination_state = update_pagination_state_with_params!(:invoice)
      condition = {:conditions => "project_id="+params[:project_id]} if params[:project_id]
      condition = {:conditions => "id="+params[:invoiceid]} if params[:invoiceid]
#      condition = {:conditions => "project_id="+params[:budget_id]} if params[:budget_id]
      @count = Invoice.count(:all,condition)
      @invoices= Invoice.find(:all,options_from_pagination_state(pagination_state).merge(condition))
  end
end
