class Status < ActiveRecord::Base
   acts_as_reportable
   set_table_name "status"
   
end
