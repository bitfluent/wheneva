class AddSubdomainIndexToAccounts < ActiveRecord::Migration
  def self.up
    add_index :accounts, :subdomain, :unique => true
  end

  def self.down
    remove_index :accounts, :column => :subdomain
  end
end
