class AddAssistantIdToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :assistant_id, :integer
  end

  def self.down
    remove_column :accounts, :assistant_id
  end
end
