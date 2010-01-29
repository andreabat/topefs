class Proceeditem< ActiveRecord::Base
    belongs_to :proceed
    belongs_to :category
    has_one    :projectitem
end
