class Document < ActiveRecord::Base
  
#  validates_presence_of :ragionesociale
#  validates_presence_of :partitaiva
#  validates_uniqueness_of(:partitaiva, :message => "Partita iva già utilizzata da un altro cliente, non è possibile duplicarla.")
#  validates_format_of :partitaiva,:with => /^(\d){11}$/i
    belongs_to :project
    belongs_to :user
    file_column :doc, :fix_file_extensions=>false
      
      def doc_mine
          doc_relative_path
      end
      
      def doc_abs
          doc_absolute_path
      end
end
