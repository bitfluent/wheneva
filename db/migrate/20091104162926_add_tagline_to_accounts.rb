class AddTaglineToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :tagline, :string
  end

  def self.down
    remove_column :accounts, :tagline
  end
end
