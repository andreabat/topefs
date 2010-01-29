class Supplier < ActiveRecord::Base
  
validates_presence_of :ragionesociale
#validates_presence_of :partitaiva
#validates_uniqueness_of(:partitaiva, :message => "Partita iva già utilizzata da un altro cliente, non è possibile duplicarla.")
#validates_format_of :partitaiva,:with => /^(\d){11}$/i
#has_many :projects
has_many :orders
  
end
