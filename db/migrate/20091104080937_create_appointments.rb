class CreateAppointments < ActiveRecord::Migration
  def self.up
    create_table :appointments do |table|
      table.string   :name, :email, :phone, :brief
      table.datetime :requested_date, :confirmed_date
      table.boolean  :cancelled, :rejected, :default => false
      table.timestamps
    end

  end

  def self.down
    drop_table :appointments
  end
end
