# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091104180942) do

  create_table "accounts", :force => true do |t|
    t.string   "title",        :null => false
    t.string   "subdomain",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",      :null => false
    t.string   "tagline"
    t.integer  "assistant_id"
  end

  add_index "accounts", ["subdomain"], :name => "index_accounts_on_subdomain", :unique => true

  create_table "appointments", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "brief"
    t.datetime "requested_date"
    t.datetime "confirmed_date"
    t.boolean  "cancelled",      :default => false
    t.boolean  "rejected",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "venue"
    t.integer  "account_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                :limit => 100, :null => false
    t.string   "encrypted_password",   :limit => 40,  :null => false
    t.string   "password_salt",        :limit => 20,  :null => false
    t.string   "reset_password_token", :limit => 20
    t.string   "remember_token",       :limit => 20
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

end
