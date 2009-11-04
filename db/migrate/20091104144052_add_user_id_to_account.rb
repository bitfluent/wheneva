class AddUserIdToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :user_id, :integer, :null => false
  end

  def self.down
    remove_column :accounts, :user_id
  end
end
