# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120327140807) do

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "item_id",    :null => false
    t.integer  "user_id",    :null => false
    t.text     "text",       :null => false
    t.string   "ancestry"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["ancestry"], :name => "index_comments_on_ancestry"
  add_index "comments", ["item_id"], :name => "index_comments_on_item_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "communities", :force => true do |t|
    t.string   "name",                          :null => false
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_public",   :default => true, :null => false
  end

  create_table "communities_users", :id => false, :force => true do |t|
    t.integer "user_id",      :null => false
    t.integer "community_id", :null => false
  end

  add_index "communities_users", ["community_id"], :name => "index_communities_users_on_community_id"
  add_index "communities_users", ["user_id", "community_id"], :name => "index_communities_users_on_user_id_and_community_id", :unique => true

  create_table "community_invitations", :force => true do |t|
    t.integer  "invitee_id",                                 :null => false
    t.integer  "inviter_id"
    t.integer  "community_id"
    t.string   "status",       :limit => 1, :default => "P"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "delegates", :force => true do |t|
    t.integer  "delegator_id"
    t.integer  "delegatee_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "delegates", ["delegatee_id"], :name => "index_delegates_on_delegatee_id"
  add_index "delegates", ["delegator_id", "delegatee_id"], :name => "index_delegates_on_delegator_id_and_delegatee_id", :unique => true

  create_table "item_preset_tags", :force => true do |t|
    t.string "tag"
    t.string "item_type"
  end

  create_table "item_visibility_rules", :force => true do |t|
    t.integer "visibility_id",   :null => false
    t.string  "visibility_type", :null => false
    t.integer "item_id",         :null => false
  end

  add_index "item_visibility_rules", ["item_id"], :name => "index_item_visibility_rules_on_item_id"
  add_index "item_visibility_rules", ["visibility_id", "visibility_type", "item_id"], :name => "uniq_item_visibility_index", :unique => true

  create_table "items", :force => true do |t|
    t.string   "title",                                   :null => false
    t.text     "description"
    t.date     "expires_on"
    t.integer  "user_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "type"
    t.string   "cost"
    t.string   "condition"
    t.string   "link"
    t.string   "location"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.boolean  "active",                :default => true, :null => false
    t.boolean  "public",                :default => true, :null => false
    t.integer  "posted_by_user_id"
    t.integer  "recommendations_count", :default => 0,    :null => false
  end

  create_table "items_tags", :id => false, :force => true do |t|
    t.integer "item_id", :null => false
    t.integer "tag_id",  :null => false
  end

  add_index "items_tags", ["item_id", "tag_id"], :name => "index_items_tags_on_item_id_and_tag_id", :unique => true
  add_index "items_tags", ["tag_id"], :name => "index_items_tags_on_tag_id"

  create_table "lists", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "lists", ["user_id"], :name => "index_lists_on_user_id"

  create_table "lists_users", :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "list_id", :null => false
  end

  add_index "lists_users", ["list_id", "user_id"], :name => "index_lists_users_on_list_id_and_user_id", :unique => true
  add_index "lists_users", ["user_id"], :name => "index_lists_users_on_user_id"

  create_table "offer_messages", :force => true do |t|
    t.integer  "offer_id"
    t.string   "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id",    :null => false
  end

  create_table "offers", :force => true do |t|
    t.integer  "item_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "recommendations", :force => true do |t|
    t.text     "description"
    t.integer  "user_id",     :null => false
    t.integer  "item_id",     :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "recommendations", ["item_id", "user_id"], :name => "index_recommendations_on_item_id_and_user_id", :unique => true

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "user_familiarities", :force => true do |t|
    t.integer "user_id",                     :null => false
    t.integer "familiar_id",                 :null => false
    t.integer "familiarness", :default => 0, :null => false
  end

  add_index "user_familiarities", ["user_id", "familiar_id"], :name => "index_user_familiarities_on_user_id_and_familiar_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "display_name"
    t.boolean  "user_set_display_name",  :default => false, :null => false
    t.boolean  "is_admin",               :default => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["display_name"], :name => "index_users_on_display_name"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vouches", :force => true do |t|
    t.integer  "voucher_id"
    t.integer  "vouchee_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "vouches", ["vouchee_id"], :name => "index_vouches_on_vouchee_id"
  add_index "vouches", ["voucher_id", "vouchee_id"], :name => "index_vouches_on_voucher_id_and_vouchee_id", :unique => true

  add_foreign_key "bookmarks", "items", :name => "bookmarks_item_id_fk"
  add_foreign_key "bookmarks", "users", :name => "bookmarks_user_id_fk"

  add_foreign_key "delegates", "users", :name => "delegates_delegatee_id_fk", :column => "delegatee_id"
  add_foreign_key "delegates", "users", :name => "delegates_delegator_id_fk", :column => "delegator_id"

  add_foreign_key "items", "users", :name => "items_posted_by_user_id_fk", :column => "posted_by_user_id"

  add_foreign_key "offer_messages", "offers", :name => "offer_messages_offer_id_fk"
  add_foreign_key "offer_messages", "users", :name => "offer_messages_user_id_fk"

  add_foreign_key "offers", "items", :name => "offers_item_id_fk"
  add_foreign_key "offers", "users", :name => "offers_user_id_fk"

end
