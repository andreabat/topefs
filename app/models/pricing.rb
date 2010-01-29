class Pricing < ActiveRecord::Base
  belongs_to :project
#  belongs_to :budget
  belongs_to :document, :dependent => :destroy
  belongs_to :user
  belongs_to :paymentmethod
  has_many :pricingitems, :dependent => :destroy
  
#  before_create :set_code
  before_create :set_code
  
  def total
      t=0
      self.pricingitems.each{|x|
          q = x.quantity ? x.quantity : 1
          t +=  (x.price)*(q)
      }
      return t
  end
  
   def set_code
     #self.project.start.year
         pri = Pricing.maximum("code_abs",:conditions => "year = #{Date.today.year}")
         pri = 0 if pri.nil?
        self.code_abs =  pri+1
        self.code= "#{self.code_abs}/#{Date.today.year}"
        self.year=Date.today.year
    end
  def un_deletable
#      logger.info ("Valore Approved:#{self.approved}")
#      logger.info ("#{Pricing.last.id} - #{self.id}")
      return true if self.approved==1
      return false
  end
end
