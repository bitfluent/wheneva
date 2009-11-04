class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |table|
      table.authenticatable
      table.validatable
      table.recoverable
      table.rememberable
      table.timestamps
    end
    add_index :users, :email
    add_index :users, :reset_password_token  # for recoverable
  end

  def self.down
    drop_table :users
  end
end
