class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :title
      t.date :start
      t.date :end
      t.text :note
      t.integer :customer_id
      t.integer :company_id
      t.timestamps
    end
    
  end

  def self.down
    drop_table :projects
  end
end
