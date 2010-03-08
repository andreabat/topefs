class Order < Coded
  include ActionView::Helpers::NumberHelper
   acts_as_reportable
  belongs_to :project
 # belongs_to :budget
  belongs_to :document
  belongs_to :user
  belongs_to :paymentmethod
  belongs_to :supplier
  has_many :orderitems, :dependent => :destroy
   before_create :set_code
  
  def total
      t=0
      self.orderitems.each{|x|
         q = x.quantity ? x.quantity : 1
          t +=  (x.cost)*(q)
      }
      return t
  end
  
  def total_report
     
      number_to_currency(self.total,:precision=>4,:delimiter=>".",:separator=>",") 
      #return form t
  end
  
  def iva_report
      return "" if self.vat.nil?
      number_to_currency(valore_iva,:precision=>2,:delimiter=>".",:separator=>",") 
  end
  
  def total_ivato_report
      number_to_currency(total+valore_iva,:precision=>4,:delimiter=>".",:separator=>",") 
  end
  
  def valore_iva
      return 0 unless self.vat
      ((self.total/100)*(self.vat) )  
  end
  
  
  def total_ivato
    t = self.total
    return t unless self.vat
    
    if t !=nil
      t+=((t/100)*(self.vat) )  
    end  
  end
  
  
#   def set_code
#        count =  Order.count(:conditions => "year = #{self.project.start.year}")
#        self.code= "#{(count+1)}-#{self.project.start.year}"
#        self.year=self.project.start.year
#    end
  
    def un_deletable
      Order.last != self
    end
end
