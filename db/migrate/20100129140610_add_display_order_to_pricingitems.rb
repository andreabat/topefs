class AddDisplayOrderToPricingitems < ActiveRecord::Migration
  def self.up
    add_column :pricingitems, :display_order, :integer
  end

  def self.down
    remove_column :pricingitems, :display_order
  end
end
