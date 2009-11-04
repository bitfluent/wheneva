class AddAccountIdToAppointments < ActiveRecord::Migration
  def self.up
    add_column :appointments, :account_id, :integer
  end

  def self.down
    remove_column :appointments, :account_id
  end
end
