class Orderitem< ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
    belongs_to :order
      acts_as_reportable

  def totale
     number_to_currency(cost * (quantity ? quantity : 1))
  end
  
  def line_description
       desc = ""
       desc = "n. #{number_with_precision(quantity,0)}  " unless !quantity
       desc += description
       desc += "  #{number_to_currency(cost)}/Cad." unless !quantity
  end
  
end
