class Projectitems < ActiveRecord::Migration
  def self.up
    add_column :projectitems, :display_order, :integer
  end

  def self.down
    remove_column  :projectitems, :display_order
  end
end
