class Invoiceitem< ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  belongs_to :invoice
  belongs_to :category
  belongs_to   :projectitem
  acts_as_reportable
  
  def category_name
    category.name.upcase
  end

  
  def totale
    number_to_currency(price * (quantity ? quantity : 1))
  end
  
  def line_description
    qty = number_with_delimiter(quantity.to_i,".","") unless !quantity
    desc = ""
    desc = "N. #{qty}  " unless !quantity
    desc += description
  end
end
