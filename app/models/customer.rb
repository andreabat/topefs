class Customer < ActiveRecord::Base
  validates_presence_of :ragionesociale
#  validates_presence_of :partitaiva
 # validates_uniqueness_of(:partitaiva, :message => "Partita iva già utilizzata da un altro cliente, non è possibile duplicarla.")
#  validates_format_of :email,:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
#  validates_format_of :prov,:with => /^[A-Za-z]{2}$/i
#  validates_format_of :partitaiva,:with => /^(\d){11}$/i
#  validates_format_of :codicefiscale,:with => /^[a-zA-Z]{6}\d\d[a-zA-Z]\d\d[a-zA-Z]\d\d\d[a-zA-Z]$/i
  has_many :projects
  acts_as_reportable
end
