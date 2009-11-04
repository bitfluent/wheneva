class ChangeLogoFromUsersToAccounts < ActiveRecord::Migration
  def self.up
    remove_column :users, :logo_file_name
    remove_column :users, :logo_content_type
    remove_column :users, :logo_file_size
    remove_column :users, :logo_updated_at
    add_column :accounts, :logo_file_name,    :string
    add_column :accounts, :logo_content_type, :string
    add_column :accounts, :logo_file_size,    :integer
    add_column :accounts, :logo_updated_at,   :datetime
  end

  def self.down
    add_column :users, :logo_file_name,    :string
    add_column :users, :logo_content_type, :string
    add_column :users, :logo_file_size,    :integer
    add_column :users, :logo_updated_at,   :datetime
    remove_column :accounts, :logo_file_name
    remove_column :accounts, :logo_content_type
    remove_column :accounts, :logo_file_size
    remove_column :accounts, :logo_updated_at
  end
end
