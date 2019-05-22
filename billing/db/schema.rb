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

ActiveRecord::Schema.define(version: 20181002075024) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "billing_code_versions", force: :cascade do |t|
    t.bigint "product_instance_id"
    t.text "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lang", null: false
    t.index ["product_instance_id"], name: "index_billing_code_versions_on_product_instance_id"
  end

  create_table "charges", force: :cascade do |t|
    t.string "type", null: false
    t.integer "product_id"
    t.string "key", null: false
    t.float "count", null: false
    t.decimal "price", null: false
    t.string "currency", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.integer "resource_id"
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "billing_units_digest", null: false
    t.bigint "product_instance_id", null: false
    t.bigint "billing_code_version_id"
    t.string "time_sequence_uid"
    t.index ["billing_code_version_id"], name: "index_charges_on_billing_code_version_id"
    t.index ["billing_units_digest"], name: "index_charges_on_billing_units_digest"
    t.index ["client_id"], name: "index_charges_on_client_id"
    t.index ["product_id"], name: "index_charges_on_product_id"
    t.index ["product_instance_id"], name: "index_charges_on_product_instance_id"
    t.index ["resource_id"], name: "index_charges_on_resource_id"
    t.index ["time_sequence_uid"], name: "index_charges_on_time_sequence_uid"
  end

  create_table "product_instances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_billing_code_version_id"
    t.index ["current_billing_code_version_id"], name: "index_product_instances_on_current_billing_code_version_id"
  end

  add_foreign_key "billing_code_versions", "product_instances"
end
