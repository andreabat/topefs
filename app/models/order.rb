class Order < Coded
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
  

  
  
  def total_ivato
    t = self.total
    return t unless self.vat
    
    if t !=nil
      ((t/100)*(self.vat) )  
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
