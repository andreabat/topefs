class ModifyProjects < ActiveRecord::Migration
  def self.up
     add_column :projects, :status_id, :integer
  end

  def self.down
    remove_column :projects, :status_id
  end
end
