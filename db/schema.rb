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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150406143401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "armor_invoices", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "product_id"
    t.float    "unit_price"
    t.integer  "count"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxes_price",    default: 0
    t.integer  "rebate_price",   default: 0
    t.integer  "rebate_percent", default: 0
    t.boolean  "deleted",        default: false
    t.integer  "user_id"
  end

  add_index "armor_invoices", ["product_id"], name: "index_armor_invoices_on_product_id", using: :btree

  create_table "armor_orders", force: :cascade do |t|
    t.integer  "buyer_id",           limit: 8
    t.integer  "seller_id",          limit: 8
    t.integer  "account_id",         limit: 8
    t.integer  "product_id"
    t.integer  "order_id",           limit: 8
    t.integer  "status"
    t.float    "unit_price"
    t.integer  "count"
    t.float    "amount"
    t.string   "summary",            limit: 100
    t.text     "description"
    t.integer  "invoice_num"
    t.integer  "purchase_order_num"
    t.datetime "status_change"
    t.string   "uri"
    t.boolean  "deleted",                        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxes_price",                    default: 0
    t.integer  "rebate_price",                   default: 0
    t.integer  "rebate_percent",                 default: 0
  end

  create_table "armor_profiles", force: :cascade do |t|
    t.integer  "armor_account", limit: 8
    t.integer  "armor_user",    limit: 8
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "armor_profiles", ["user_id"], name: "index_armor_profiles_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "certificates", force: :cascade do |t|
    t.string   "filename"
    t.string   "content_type"
    t.binary   "data"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "certificates", ["user_id"], name: "index_certificates_on_user_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "image_file_name"
    t.string   "image_file_size"
    t.string   "image_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["product_id"], name: "index_images_on_product_id", using: :btree

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id", using: :btree
  add_index "mailboxer_conversation_opt_outs", ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type", using: :btree

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.string   "notification_code"
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "attachment"
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree
  add_index "mailboxer_notifications", ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type", using: :btree
  add_index "mailboxer_notifications", ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type", using: :btree
  add_index "mailboxer_notifications", ["type"], name: "index_mailboxer_notifications_on_type", using: :btree

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree
  add_index "mailboxer_receipts", ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type", using: :btree

  create_table "pricebreaks", force: :cascade do |t|
    t.integer  "quantity"
    t.float    "price"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pricebreaks", ["product_id"], name: "index_pricebreaks_on_product_id", using: :btree

  create_table "product_categories", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "sku"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.float    "unit_price"
    t.boolean  "status",                default: true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status_action"
    t.string   "status_characteristic"
    t.integer  "amount"
    t.integer  "sold_out"
    t.string   "dimension_width"
    t.string   "dimension_height"
    t.string   "dimension_depth"
    t.string   "dimension_weight"
    t.integer  "main_category"
    t.integer  "tax_id"
  end

  add_index "products", ["tax_id"], name: "index_products_on_tax_id", using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "taxes", force: :cascade do |t|
    t.string   "name"
    t.decimal  "value",      precision: 5, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "phone"
    t.string   "company"
    t.string   "location"
    t.string   "zip_code"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "facebook"
    t.string   "ein_tax"
    t.boolean  "receive_private_info",   default: true
    t.boolean  "receive_new_offer",      default: true
    t.boolean  "receive_tips",           default: true
    t.string   "asset_file_name"
    t.string   "asset_file_size"
    t.string   "asset_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "benefits"
    t.boolean  "is_reseller",            default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
end
