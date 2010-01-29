class Invoiceitem< ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  belongs_to :invoice
  belongs_to :category
  has_one    :projectitem
  acts_as_reportable
  
  def totale
    number_to_currency(price * (quantity ? quantity : 1))
  end
  
  def line_description
    desc = ""
    desc = "N. #{number_with_precision(quantity,0)}  " unless !quantity
    desc += description
  end
end
