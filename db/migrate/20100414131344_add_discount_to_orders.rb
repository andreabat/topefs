class AddDiscountToOrders < ActiveRecord::Migration
   def self.up
     add_column :orders, :discount, :integer
  end

  def self.down
     remove_column :orders, :discount
  end
end
