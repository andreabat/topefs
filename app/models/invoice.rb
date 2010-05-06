class Invoice < Coded
  include ActionView::Helpers::NumberHelper
   acts_as_reportable
  belongs_to :project
 # belongs_to :budget
  belongs_to :document, :dependent => :destroy
  belongs_to :pricing
  belongs_to :user
  belongs_to :paymentmethod
  has_many :invoiceitems, :dependent => :destroy
  has_many :proceeds
  before_create :set_code

   def status
     description = ""
     if (self.expired&&self.payed!=true)
        description ="Scaduta"
      else
        description ="Non scaduta"
      end 
      
      if(self.payed)
        description += "| Pagata" 
      else 
        description += "| NON Pagata" 
      end
      
      description
        
   end
  
#  def expires
#    d = self.paymentmethod.paymentmethod.to_i
#    Date.parse(self.created_at.strftime('%Y/%m/%d'))+60
#  end
  
  def customer
  	self.project.customer.ragionesociale
  end
  
  def expiration
    #la data di scadenza calcolata aggiungendo i numeri di giorni presenti in expires
    #con la data di creazione
    return "" if (self.expires.nil?)
    return "" if (self.expires==0)
    Date.parse(self.created_at.strftime('%Y/%m/%d'))+self.expires.to_i
  end

  def expired
    return false if expiration==""
    return true if  (expiration==Date.today)
     return false if  (expiration>Date.today)
  end
  
  def total
      imponibile unless @c_imponibile
      iva unless @c_iva
      return @c_imponibile + @c_iva
  end
  
  def imponibile
    t=0
      self.invoiceitems.each{|x|
         q = x.quantity ? x.quantity : 1
          t +=  (x.price)*(q)
      }
      @c_imponibile=t
      if (self.discount)
          #logger.debug("Vado a sottrarre #{@c_imponibile} da #{self.discount}")
          @c_imponibile -= self.discount unless @c_imponibile==0
      end
      return @c_imponibile
  end
  
  def iva
      if (!@c_imponibile) 
        self.imponibile
      end
      self.vat=0 unless self.vat!=nil
     @c_iva = (@c_imponibile/100).to_f*self.vat
    return @c_iva
  end
  
  def income
    t=0
    self.proceeds.each{|x|
        t+=x.amount if x.amount
    }
    return t
  end
  
#   def set_code
#        count =  Invoice.count(:conditions => "year = #{self.project.start.year}")
#        self.code= "#{(count+1)}/#{self.project.start.year}"
#        self.year=self.project.start.year
#    end
    def un_deletable
      f = (Invoice.last==self) && self.proceeds.length==0 && self.payed!=true
      return !f
  end
  
  
  
end
