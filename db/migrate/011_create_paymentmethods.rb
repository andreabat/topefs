class CreatePaymentmethods < ActiveRecord::Migration
  def self.up
    create_table :paymentmethods do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :paymentmethods
  end
end
