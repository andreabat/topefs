class Project < Coded
  include ActionView::Helpers::NumberHelper
    validates_presence_of :customer
    before_create :set_code
    belongs_to :customer
    belongs_to :company
    belongs_to :status
    belongs_to :user
    has_many :invoices
    has_many :orders
    has_many :pricings
    has_many :projectitems, :dependent => :destroy
    has_many :proceeds
    acts_as_reportable
    
    def invoiced_orders_total
       t=0
       self.orders.each{ |i| 
       t+=i.amount_invoice unless  !i.amount_invoice
       }
       t
    end

    def items_cost_total
       t=0
       self.projectitems.each{ |i| 
         t+=i.cost*(i.quantity ? i.quantity : 1) 
       }
       t
    end

     def payed_orders_total
       t=0
       n=0
       self.orders.each{ |i| 
           if (i.payed_invoice=1)  
           t+=i.amount_invoice unless  !i.amount_invoice
         else
           n+=i.amount_invoice unless  !i.amount_invoice
           end
       }
       {:payed=>t,:not_payed=>n}
    end
    
    
    def invoice_total
       t=0
       self.invoices.each{ |i| t+=i.total unless !i.total}
       t
    end
    
     def pricing_total
       t=0
       self.pricings.find_all_by_approved(true).each{ |i| t+=i.total unless !i.total}
       t
    end
    
    def approved_pricings
      a = []
      a << "<ul>"
      a << self.pricings.find_all_by_approved(true).collect{|x| 
          "<li><a  target='_blank' href='/documents/show/#{x.document_id}'>#{x.code}</a></li>"
          }
          
      a << "</ul>"
      a.join("")
    end
    
    def approved_invoices
      a = []
      a << "<ul>"
      a << self.invoices.find(:all,:conditions=>["deleted=0"]).collect{|x| 
          "<li><a  target='_blank' href='/documents/show/#{x.document_id}'>#{x.code}</a></li>"
          }
      a << "</ul>"
      a.join("")
    end
    
    def order_total
       t=0
       self.orders.each{ |i| t+=i.total_ivato}
       t
    end
    
    def proceed_total
        t=0
        self.proceeds.each{|i| t+=i.amount if i.amount}
        t
    end
    
#    def set_code
#        count =  Project.count(:conditions => "year = #{self.start.year}")
#        self.code= "#{(count+1)}/#{self.start.year}"
#        self.year=self.start.year
#    end
    def total
      #presente al momento per non far sbroccare il missing method
      #di pricing. Chissà perchè lo cerca in project ????
    end
    def un_deletable
      self.invoices.length>0||self.proceeds.length>0||self.orders.length>0
    end
end
