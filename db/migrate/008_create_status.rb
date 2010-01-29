class CreateStatus < ActiveRecord::Migration
  def self.up
    create_table "status" do |t|
      t.column :status, :string
      t.timestamps
    end
    Status.create :status=>"Aperto"
    Status.create :status=>"Chiuso"
    Status.create :status=>"Preventivo"
    Status.create :status=>"Budget"

  end

  def self.down
    drop_table "status"
  end
end