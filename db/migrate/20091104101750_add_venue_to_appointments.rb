class AddVenueToAppointments < ActiveRecord::Migration
  def self.up
    add_column :appointments, :venue, :string
  end

  def self.down
    remove_column :appointments, :venue
  end
end
