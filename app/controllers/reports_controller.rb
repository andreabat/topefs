#require 'ruport'
#require "ruport/util"
#require 'htmldoc'

class ReportsController < ApplicationController 
  before_filter :login_required
  require_role ["admin","account"]
 #include Invoice
 def view
  @graph = open_flash_chart_object(500,250, '/reports/report1?id='<<params[:project_id], true, '/')     
  render :layout=>false
end
 
 def costi_commessa
   @project=Project.find(params[:id])
   
   @costi_vivi = Projectitem.find(:first,:select=>"sum(cost*coalesce(quantity,1)) as vivi",:conditions=>["(price=0 or price is null) and project_id=?",params[:id]]).vivi.to_i
    @costi_vivi = 0 if @costi_vivi==nil
    print @costi_vivi
    @costi_fornitore = 0
    
    #orders=Order.find_all_by_project_id(params[:id])
    #orders.each{|x| @costi_fornitore+=x.total}
    @project.projectitems.each{|p|
              @costi_fornitore+=(p.cost* (p.quantity ? p.quantity : 1) ) unless p.price==0
           
    }
    
    
    ts = Timesheet.find_all_by_project_id(params[:id])
    @costi_personale = 0
     ts.each{|x| @costi_personale+=x.cost}
   
   data =[]
   data << @costi_vivi
   data << @costi_fornitore
   data << @costi_personale
   
  g = Graph.new
  g.pie(60, '#505050', '{font-size: 12px; color: #404040;}')
  g.pie_values(data, %w(Vivi Fornitori Personale))
  g.pie_slice_colors(%w(#d01fc3 #356aa0 #c79810))
  g.set_tool_tip("#val#")
  g.title("Costi", '{font-size:18px; color: #d01f3c}' )
  render :text => g.render

   
   
 end
 
 def report1
   p=Project.find(params[:id])
   bar1 = BarFade.new(55, '#C31812')
   bar1.key('costi', 10)

   bar2 = BarFade.new(55, '#424581')
   bar2.key('incassato', 10)
   
   bar3 = BarFade.new(55, '#421531')
   bar3.key('preventivato', 10)


   
          bar1.data << p.order_total
          bar2.data << p.proceed_total
          bar3.data << p.pricing_total
  

  g = Graph.new
  g.title("Prospetto Finanze", '{font-size:20px; color: #bcd6ff; margin:10px; background-color: #5E83BF; padding: 5px 15px 5px 15px;}')
  g.data_sets << bar1
  g.data_sets << bar2
  g.data_sets << bar3
  g.set_x_labels([p.title])
  g.set_x_axis_color('#909090', '#D2D2FB')
  g.set_y_axis_color('#909090', '#D2D2FB')
  g.set_y_max(p.pricing_total)
  g.set_y_format("€ #val#")
  g.set_num_decimals(2)
  g.set_is_thousand_separator_disabled(false)
  g.set_is_decimal_separator_comma(true)
  g.set_is_fixed_num_decimals_forced(true)
  g.set_y_label_steps(6)
  g.set_y_legend("Finanze", 12, '#736AFF')
  render :text => g.render
 end
 
#  def topogigio
##    a = Ruport::Data::Record.new ["1.8.5","0.9.2","darwin8.8.2"],
##        :attributes => ["ruby_version", "rubygems_version", "host_os"]
##  b = Ruport::Data::Record.new({ :ruby_version => "1.8.5",
##        :rubygems_version => "0.9.2",
##        :host_os => "darwin8.8.2" })
##     
###   render   :inline=>"Ciao Topo"
##    Invoice()
##    @table = Table(%w[a b c]) { |t| t << [1,2,3] << [4,5,6] }
##    send_data render_to_pdf({ :action => 'table.rpdf', :layout => 'pdf_report' }),:filename => "table.pdf"
#
#  render_invoice do |i|
#      i.data = Table("Item Number","Description","Price") { |t|
#        t << %w[101 Erlang\ The\ Movie $1000.00]
#        t << %w[102 Erlang\ The\ Book $45.95] 
#      }
#      i.company_info  = "Stone Code Productions\n43 Neagle Street"
#      i.customer_info = "Gregory Brown\n200 Foo Ave.\n"
#      i.comments      = "Hello Mike!  Hello Joe!"
#      i.order_info    = "Some info\nabout your order"
#      i.title         = "Invoice for 12.15.2006 - 12.31.2006"
#      i.options do |o|
#        o.body_width = 480
#        o.comments_font_size = 12
#        o.title_font_size = 10  
#      end
#end
#  end
#
#  def htmldoc
#        @items   = Customer.find(:all)
#          respond_to do |format|
#      format.html {render :location=>"htmldoc.rpdf",:layout => 'pdf_report.pdf.erb' }
#      format.xml { head :ok }
#      format.pdf { send_data render_to_pdf({ :action => 'htmldoc.rpdf', :layout => 'pdf_report' }),:filename => "foobar.pdf" }
#    end
#        
#  end
#
#  def show
#        @customer   = Customer.find(953125641)
#        respond_to do |format|
#                format.html # show.html.erb
#                format.pdf { render :action => 'show' }
#        end
#      
#      def getpdf
#          @paper='A4'
#    end 
#
#  end

end
