
class Pricingitem< ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
    belongs_to :pricing
  belongs_to :category
  acts_as_reportable

def category_name
  category.name
end

def totale
  number_to_currency(price * ( quantity ? quantity : 1))
end
def price_label
  a= number_to_currency(price,:precision=>4).split(",") 
  a[1].gsub!(/0+$/,"") unless a[1]==nil
  s=a[0]
  s = a.join(",")unless a[1]==nil||a[1]==""
  s
end
def qty_label
  a = sprintf("%.#{2}f", quantity) #unless a==nil
  a.gsub(".00","").gsub(".",",") unless a==nil
  a
end

end
