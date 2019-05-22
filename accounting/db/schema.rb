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

ActiveRecord::Schema.define(version: 2018_10_22_095311) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "discount_packages", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discount_sets", force: :cascade do |t|
    t.integer "discount_id", null: false
    t.integer "discount_package_id", null: false
    t.decimal "amount", precision: 10, scale: 4, null: false
    t.string "amount_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discount_id", "discount_package_id"], name: "index_discount_sets_on_discount_id_and_discount_package_id", unique: true
    t.index ["discount_id"], name: "index_discount_sets_on_discount_id"
    t.index ["discount_package_id"], name: "index_discount_sets_on_discount_package_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.string "key_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 4, null: false
    t.string "currency", null: false
    t.integer "client_id", null: false
    t.string "subject_type", null: false
    t.integer "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_type", default: "money", null: false
    t.index ["client_id"], name: "index_payment_transactions_on_client_id"
    t.index ["subject_id"], name: "index_payment_transactions_on_subject_id"
    t.index ["subject_type", "subject_id", "account_type"], name: "subject_on_account_type", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 4, null: false
    t.string "currency", null: false
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "puid", null: false
    t.string "source", null: false
    t.index ["puid", "source"], name: "index_payments_on_puid_and_source", unique: true
  end

  create_table "product_instance_states", force: :cascade do |t|
    t.integer "writeoff_id", null: false
    t.integer "product_id", null: false
    t.integer "product_instance_id", null: false
    t.jsonb "billing_data", default: {}, null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["writeoff_id"], name: "index_product_instance_states_on_writeoff_id"
  end

  create_table "writeoffs", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 4
    t.decimal "initial_amount", precision: 15, scale: 4
    t.string "currency", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.integer "client_id", null: false
    t.datetime "paid_at"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "start_date", "end_date"], name: "index_writeoffs_on_client_id_and_start_date_and_end_date", unique: true
    t.index ["client_id"], name: "index_writeoffs_on_client_id"
  end

end
