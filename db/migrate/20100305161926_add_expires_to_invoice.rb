class AddExpiresToInvoice < ActiveRecord::Migration
  def self.up
     add_column :invoices, :expires, :integer
  end

  def self.down
     remove_column :invoices, :expires
  end
end
