class Company < ActiveRecord::Base
 

def ccn
	"#{self.cap} #{self.comune} - Italia"
end
end
