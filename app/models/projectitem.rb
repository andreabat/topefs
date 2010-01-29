class Projectitem< ActiveRecord::Base
    belongs_to :project
    belongs_to :category
    attr_accessor :new_category_name
    attr_accessor :invoiced
    attr_accessor :priced
    attr_accessor :ordered
    attr_accessor :pricedna
    before_save :create_category_from_name

   def create_category_from_name
        self.category = create_category(:name=>new_category_name) unless new_category_name.blank?
   end
   
   def invoiced
      conditions={"projectitem_id"=>self.id,"invoices.deleted"=>0,"invoices.payed"=>0}
      return  Invoiceitem.count(:joins=>:invoice,:conditions=>conditions)>0
  end
  def ordered
      conditions={"projectitem_id"=>self.id,"orders.deleted"=>0,"orders.payed_invoice"=>0,"orders.received_invoice"=>0}
      return  Orderitem.count(:joins=>:order,:conditions=>conditions)>0
  end
  def priced
      conditions={"projectitem_id"=>self.id,"pricings.approved"=>1}
      return  Pricingitem.count(:joins=>:pricing,:conditions=>conditions)>0
  end
  def pricedna
      return nil if (priced)
      
      conditions={"projectitem_id"=>self.id,"pricings.approved"=>0}
      return  Pricingitem.count(:joins=>:pricing,:conditions=>conditions)>0
  end
  def pricings
      conditions={"projectitem_id"=>self.id}
      projects = Array.new
      Pricingitem.find(:conditions=>conditions) do|pr|
          projects<<pr.project.id
      end
  end
   
end
