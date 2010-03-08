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
    
    def method_missing(method, *args)
    if ( method.to_s =~ /^euro_(.*)$/)
       result = self.send($1.to_sym,*args)
       return number_to_currency(result,:precision=>4,:delimiter=>".",:separator=>",")
    else 
      super
    end
  end
  def respond_to?(method_sym, include_private = false)
    if method_sym.to_s =~ /^euro_(.*)$/
      true
    else
      super
    end
  end
    
end