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

ActiveRecord::Schema.define(version: 20160829043337) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "line1"
    t.string   "line2"
    t.string   "zip"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "amg_orders", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "product_id"
    t.integer  "status"
    t.float    "unit_price"
    t.integer  "count"
    t.float    "fee"
    t.float    "rebate"
    t.float    "total"
    t.string   "summary"
    t.text     "description"
    t.string   "tracking_number"
    t.boolean  "deleted"
    t.float    "shipping_cost"
    t.string   "address_name"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "address_country"
    t.integer  "shipping_estimate_id"
    t.integer  "address_id"
    t.string   "transaction_id"
    t.string   "authorization_code"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "amg_profiles", force: :cascade do |t|
    t.string   "amg_api_key"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "username"
    t.string   "password"
  end

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
    t.integer  "buyer_id",                   limit: 8
    t.integer  "seller_id",                  limit: 8
    t.integer  "account_id",                 limit: 8
    t.integer  "product_id"
    t.integer  "order_id",                   limit: 8
    t.integer  "status",                                 default: 0
    t.float    "unit_price"
    t.integer  "count"
    t.float    "amount"
    t.string   "summary",                    limit: 100
    t.text     "description"
    t.integer  "invoice_num"
    t.integer  "purchase_order_num"
    t.datetime "status_change"
    t.string   "uri"
    t.boolean  "deleted",                                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxes_price",                            default: 0
    t.integer  "rebate_price",                           default: 0
    t.integer  "rebate_percent",                         default: 0
    t.float    "fee"
    t.float    "rebate"
    t.float    "shipping_cost"
    t.boolean  "inspection_complete",                    default: false
    t.string   "payment_release_url"
    t.boolean  "payment_release",                        default: false
    t.boolean  "funds_in_escrow",                        default: false
    t.float    "seller_charged_fee"
    t.float    "amount_after_fee_to_seller"
  end

  create_table "armor_profiles", force: :cascade do |t|
    t.integer  "armor_account_id", limit: 8
    t.integer  "armor_user_id",    limit: 8
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed_email"
    t.boolean  "agreed_terms"
  end

  add_index "armor_profiles", ["user_id"], name: "index_armor_profiles_on_user_id", using: :btree

  create_table "blogo_posts", force: :cascade do |t|
    t.integer  "user_id",          null: false
    t.string   "permalink",        null: false
    t.string   "title",            null: false
    t.boolean  "published",        null: false
    t.datetime "published_at",     null: false
    t.string   "markup_lang",      null: false
    t.text     "raw_content",      null: false
    t.text     "html_content",     null: false
    t.text     "html_overview"
    t.string   "tags_string"
    t.string   "meta_description", null: false
    t.string   "meta_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogo_posts", ["permalink"], name: "index_blogo_posts_on_permalink", unique: true, using: :btree
  add_index "blogo_posts", ["published_at"], name: "index_blogo_posts_on_published_at", using: :btree
  add_index "blogo_posts", ["user_id"], name: "index_blogo_posts_on_user_id", using: :btree

  create_table "blogo_taggings", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "tag_id",  null: false
  end

  add_index "blogo_taggings", ["tag_id", "post_id"], name: "index_blogo_taggings_on_tag_id_and_post_id", unique: true, using: :btree

  create_table "blogo_tags", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogo_tags", ["name"], name: "index_blogo_tags_on_name", unique: true, using: :btree

  create_table "blogo_users", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "email",           null: false
    t.string   "password_digest", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogo_users", ["email"], name: "index_blogo_users_on_email", unique: true, using: :btree

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
    t.integer  "product_id"
  end

  add_index "certificates", ["user_id"], name: "index_certificates_on_user_id", using: :btree

  create_table "commontator_comments", force: :cascade do |t|
    t.string   "creator_type"
    t.integer  "creator_id"
    t.string   "editor_type"
    t.integer  "editor_id"
    t.integer  "thread_id",                     null: false
    t.text     "body",                          null: false
    t.datetime "deleted_at"
    t.integer  "cached_votes_up",   default: 0
    t.integer  "cached_votes_down", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_comments", ["cached_votes_down"], name: "index_commontator_comments_on_cached_votes_down", using: :btree
  add_index "commontator_comments", ["cached_votes_up"], name: "index_commontator_comments_on_cached_votes_up", using: :btree
  add_index "commontator_comments", ["creator_id", "creator_type", "thread_id"], name: "index_commontator_comments_on_c_id_and_c_type_and_t_id", using: :btree
  add_index "commontator_comments", ["thread_id", "created_at"], name: "index_commontator_comments_on_thread_id_and_created_at", using: :btree

  create_table "commontator_subscriptions", force: :cascade do |t|
    t.string   "subscriber_type", null: false
    t.integer  "subscriber_id",   null: false
    t.integer  "thread_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_subscriptions", ["subscriber_id", "subscriber_type", "thread_id"], name: "index_commontator_subscriptions_on_s_id_and_s_type_and_t_id", unique: true, using: :btree
  add_index "commontator_subscriptions", ["thread_id"], name: "index_commontator_subscriptions_on_thread_id", using: :btree

  create_table "commontator_threads", force: :cascade do |t|
    t.string   "commontable_type"
    t.integer  "commontable_id"
    t.datetime "closed_at"
    t.string   "closer_type"
    t.integer  "closer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "commontator_threads", ["commontable_id", "commontable_type"], name: "index_commontator_threads_on_c_id_and_c_type", unique: true, using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "emb_orders", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "product_id"
    t.integer  "status",               default: 0
    t.float    "unit_price"
    t.integer  "count"
    t.float    "fee"
    t.float    "rebate"
    t.float    "total"
    t.string   "summary"
    t.text     "description"
    t.string   "tracking_number"
    t.boolean  "deleted",              default: false, null: false
    t.float    "shipping_cost"
    t.string   "address_name"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "address_country"
    t.integer  "shipping_estimate_id"
    t.integer  "address_id"
    t.string   "transaction_id"
    t.string   "authorization_code"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "emb_profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fees", force: :cascade do |t|
    t.string   "module_name"
    t.decimal  "value",       precision: 5, scale: 3
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "green_checks", force: :cascade do |t|
    t.string   "result"
    t.string   "result_description"
    t.string   "check_number"
    t.string   "check_id"
    t.integer  "green_order_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.float    "amount"
  end

  create_table "green_orders", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "product_id"
    t.string   "check_number"
    t.string   "check_id"
    t.integer  "status",                           default: 0
    t.float    "unit_price"
    t.integer  "count"
    t.float    "fee"
    t.float    "rebate"
    t.float    "total"
    t.string   "summary",              limit: 100
    t.text     "description"
    t.string   "tracking_number"
    t.boolean  "deleted",                          default: false, null: false
    t.float    "shipping_cost"
    t.string   "address_name"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "address_country"
    t.integer  "shipping_estimate_id"
    t.integer  "address_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "green_profiles", force: :cascade do |t|
    t.string   "green_client_id"
    t.string   "green_api_password"
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "image_file_name"
    t.string   "image_file_size"
    t.string   "image_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["product_id"], name: "index_images_on_product_id", using: :btree

  create_table "impressions", force: :cascade do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "inspection_dates", force: :cascade do |t|
    t.datetime "date"
    t.string   "creator_type"
    t.integer  "product_id"
    t.integer  "armor_order_id"
    t.boolean  "approved"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

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

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "armor_order_id"
    t.string   "title"
    t.boolean  "read",            default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "amg_order_id"
    t.integer  "emb_order_id"
    t.integer  "stripe_order_id"
    t.integer  "green_order_id"
    t.boolean  "deleted",         default: false
  end

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
    t.boolean  "status",                          default: true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status_action"
    t.string   "status_characteristic"
    t.integer  "amount"
    t.integer  "sold_out",              limit: 8, default: 0,    null: false
    t.string   "dimension_width"
    t.string   "dimension_height"
    t.string   "dimension_depth"
    t.string   "dimension_weight"
    t.integer  "main_category"
    t.integer  "type",                            default: 0
    t.integer  "views_count",                     default: 0
    t.datetime "deleted_at"
    t.boolean  "negotiable"
    t.string   "default_payment"
  end

  add_index "products", ["deleted_at"], name: "index_products_on_deleted_at", using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "refund_requests", force: :cascade do |t|
    t.integer  "green_order_id"
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "status",         default: 0
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "deleted",        default: false
  end

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

  create_table "searchjoy_searches", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "search_type"
    t.string   "query"
    t.string   "normalized_query"
    t.integer  "results_count"
    t.datetime "created_at"
    t.integer  "convertable_id"
    t.string   "convertable_type"
    t.datetime "converted_at"
  end

  add_index "searchjoy_searches", ["convertable_id", "convertable_type"], name: "index_searchjoy_searches_on_convertable_id_and_convertable_type", using: :btree
  add_index "searchjoy_searches", ["created_at"], name: "index_searchjoy_searches_on_created_at", using: :btree
  add_index "searchjoy_searches", ["search_type", "created_at"], name: "index_searchjoy_searches_on_search_type_and_created_at", using: :btree
  add_index "searchjoy_searches", ["search_type", "normalized_query", "created_at"], name: "index_searchjoy_searches_on_search_type_and_normalized_query_an", using: :btree

  create_table "shipping_estimates", force: :cascade do |t|
    t.integer  "product_id"
    t.float    "cost"
    t.text     "description"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "type",        default: "PerUnit", null: false
  end

  add_index "shipping_estimates", ["product_id"], name: "index_shipping_estimates_on_product_id", using: :btree

  create_table "stripe_cards", force: :cascade do |t|
    t.integer  "stripe_customer_id"
    t.string   "stripe_card_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "stripe_customers", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_customer_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "stripe_orders", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "product_id"
    t.string   "stripe_charge_id"
    t.integer  "status",                           default: 0
    t.float    "unit_price"
    t.integer  "count"
    t.float    "fee"
    t.float    "rebate"
    t.float    "total"
    t.string   "summary",              limit: 100
    t.text     "description"
    t.string   "tracking_number"
    t.boolean  "deleted",                          default: false, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.float    "shipping_cost"
    t.string   "address_name"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "address_country"
    t.integer  "stripe_card_id"
    t.integer  "shipping_estimate_id"
    t.integer  "address_id"
  end

  add_index "stripe_orders", ["address_id"], name: "index_stripe_orders_on_address_id", using: :btree
  add_index "stripe_orders", ["shipping_estimate_id"], name: "index_stripe_orders_on_shipping_estimate_id", using: :btree
  add_index "stripe_orders", ["stripe_card_id"], name: "index_stripe_orders_on_stripe_card_id", using: :btree

  create_table "stripe_profiles", force: :cascade do |t|
    t.string   "stripe_publishable_key"
    t.string   "stripe_uid"
    t.string   "stripe_access_code"
    t.integer  "user_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "stripe_profiles", ["user_id"], name: "index_stripe_profiles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                            default: "",    null: false
    t.string   "encrypted_password",               default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,     null: false
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
    t.string   "facebook"
    t.string   "ein_tax"
    t.boolean  "receive_private_info",             default: true
    t.boolean  "receive_new_offer",                default: true
    t.boolean  "receive_tips",                     default: true
    t.string   "asset_file_name"
    t.string   "asset_file_size"
    t.string   "asset_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "benefits"
    t.boolean  "is_reseller",                      default: false
    t.integer  "armor_account_id",       limit: 8
    t.integer  "armor_user_id",          limit: 8
    t.boolean  "terms_of_service"
    t.datetime "terms_accepted_at"
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

  create_table "videos", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "video_file_name"
    t.string   "video_file_size"
    t.string   "video_content_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
  add_foreign_key "shipping_estimates", "products"
  add_foreign_key "stripe_orders", "addresses"
  add_foreign_key "stripe_orders", "shipping_estimates"
  add_foreign_key "stripe_orders", "stripe_cards"
  add_foreign_key "stripe_profiles", "users"
end
