class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |table|
      table.string :email, :null => false
      table.string :password, :null => false
      table.timestamps
    end

  end

  def self.down
    drop_table :users
  end
end
