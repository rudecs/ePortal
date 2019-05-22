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

ActiveRecord::Schema.define(version: 2018_09_17_105917) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "notifications", force: :cascade do |t|
    t.integer "notifications_request_id", null: false
    t.integer "user_id"
    t.text "content", null: false
    t.integer "template_id"
    t.integer "delivery_method", null: false
    t.string "destination"
    t.datetime "delivered_at"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifications_request_id"], name: "index_notifications_on_notifications_request_id"
  end

  create_table "notifications_requests", force: :cascade do |t|
    t.datetime "processed_at"
    t.string "key_name"
    t.text "content"
    t.integer "delivery_method"
    t.integer "client_ids", default: [], array: true
    t.string "category"
    t.integer "user_ids", default: [], array: true
    t.jsonb "provided_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "emails", default: [], array: true
    t.string "phones", default: [], array: true
  end

  create_table "templates", force: :cascade do |t|
    t.integer "templates_set_id", null: false
    t.text "content", null: false
    t.string "locale", null: false
    t.integer "delivery_method", null: false
    t.string "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["templates_set_id", "locale", "delivery_method"], name: "templates_set_locale_delivery", unique: true
    t.index ["templates_set_id"], name: "index_templates_on_templates_set_id"
  end

  create_table "templates_sets", force: :cascade do |t|
    t.string "key_name"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_name"], name: "index_templates_sets_on_key_name", unique: true
  end

end
