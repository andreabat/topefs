class Orderitem< ActiveRecord::Base
    include ActionView::Helpers::NumberHelper
    belongs_to :order
    belongs_to :projectitem

      acts_as_reportable


  def category_name
 	 projectitem.category.name.upcase
  end



  def totale
     number_to_currency(cost * (quantity ? quantity : 1))
  end
  
  def line_description
      #MODIFICA CAROLA 20100219 In attesa di approvazione
       qty = number_with_delimiter(quantity.to_i,".","") unless !quantity
       outc = number_to_currency(cost,:precision=>2,:delimiter=>".",:separator=>",") unless !quantity
#       puts  "RESULTING COST IS #{outc}"
       desc = ""
       desc = "n. #{qty}  " unless !quantity
       desc += description
       desc += "  #{outc}/Cad." unless !quantity
  end
  
end
