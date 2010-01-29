class CreatePricings < ActiveRecord::Migration
  def self.up
    create_table :pricings do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :pricings
  end
end
