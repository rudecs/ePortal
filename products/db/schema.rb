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

ActiveRecord::Schema.define(version: 20181120141450) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "handler_arenadatas", force: :cascade do |t|
    t.integer "product_instance_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "handler_vdcs", force: :cascade do |t|
    t.integer "product_instance_id", null: false
    t.integer "location_id"
    t.integer "cloud_space_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "handler_vms", force: :cascade do |t|
    t.integer "product_instance_id", null: false
    t.integer "product_instance_vdc_id"
    t.integer "machine_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
  end

  create_table "product_instance_jobs", force: :cascade do |t|
    t.integer "product_instance_id"
    t.integer "playbook_id"
    t.string "state"
    t.datetime "created_at"
    t.datetime "finished_at"
    t.string "action_name"
    t.json "action_params"
    t.json "error_messages"
  end

  create_table "product_instances", force: :cascade do |t|
    t.integer "product_id"
    t.integer "client_id"
    t.integer "playbook_id"
    t.string "name"
    t.string "state"
    t.string "type"
    t.json "error_messages"
    t.string "handler_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "disabled_at"
    t.string "disabled_status"
    t.string "description"
  end

  create_table "products", force: :cascade do |t|
    t.string "name_ru"
    t.string "description_ru"
    t.string "type"
    t.string "state"
    t.string "handler_api"
    t.string "handler_price"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "name_en"
    t.string "description_en"
    t.string "additional_description_en"
    t.string "additional_description_ru"
  end

  create_table "resources", force: :cascade do |t|
    t.integer "product_instance_id"
    t.string "type"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
