class CreateProceeds < ActiveRecord::Migration
  def self.up
    create_table :proceeds do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :proceeds
  end
end
