class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :ragionesociale
      t.string :partitaiva
      t.string :codicefiscale
      t.string :indirizzo
      t.string :civico
      t.string :comune
      t.string :cap
      t.string :prov
      t.text :note
      t.string :telefono
      t.string :fax
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
