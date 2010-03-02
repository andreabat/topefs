class Timesheet < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  set_table_name "timesheet"
  
  def cost
    self.hours*self.user.hourly_cost
  end
  
end
