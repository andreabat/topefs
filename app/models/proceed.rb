class Proceed < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :invoice
end
