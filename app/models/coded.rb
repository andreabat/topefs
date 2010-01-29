class Coded < ActiveRecord::Base
  self.abstract_class=true
  
  def from_db
    self.class.find self.id
  end
  
   def set_code
        count =  self.class.count(:conditions => "year = #{Date.today.year}")
        count=0 if count.nil?
        self.code= "#{(count+1)}/#{Date.today.year}"
        
        self.year=Date.today.year
    end
end