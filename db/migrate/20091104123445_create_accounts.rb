class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |table|
      table.string :title, :null => false
      table.string :subdomain, :null => false
      table.timestamps
    end

  end

  def self.down
    drop_table :accounts
  end
end
