class AddTokenToAppointments < ActiveRecord::Migration
  def self.up
    add_column :appointments, :token, :string
  end

  def self.down
    remove_column :appointments, :token
  end
end
