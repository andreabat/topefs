class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :ragionesociale
      t.string :indirizzo
      t.string :comune
      t.string :cap
      t.string :prov
      t.string :coordinatebancarie
      t.string :telefono
      t.string :partitaiva
      t.string :codicefiscale
      t.string :telefono
      t.string :email
      t.string :fax
      t.timestamps
    end
    Company.create :ragionesociale=>"Cube Studio"
    Customer.create :ragionesociale=>"Monini"
    Project.create :title=>"Progetto Monini", :customer_id=>1, :company_id=>1
  end

  def self.down
    drop_table :companies
  end
end
