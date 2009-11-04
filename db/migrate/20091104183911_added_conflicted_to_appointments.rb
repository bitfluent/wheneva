class AddedConflictedToAppointments < ActiveRecord::Migration
  def self.up
    add_column :appointments, :conflicted, :boolean, :default => false
  end

  def self.down
    remove_column :appointments, :conflicted
  end
end
