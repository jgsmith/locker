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

ActiveRecord::Schema.define(:version => 5) do

  create_table "group_memberships", :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "groups", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.boolean "members_can_contribute", :default => false
  end

  create_table "groups_uploads", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "upload_id"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tags_uploads", :id => false, :force => true do |t|
    t.integer "upload_id"
    t.integer "tag_id"
  end

  create_table "uploads", :force => true do |t|
    t.integer  "user_id"
    t.string   "display_name"
    t.string   "filename"
    t.integer  "size"
    t.string   "content_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "uin",                       :limit => 9
    t.string   "email"
    t.string   "name"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
