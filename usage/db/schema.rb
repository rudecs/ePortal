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

ActiveRecord::Schema.define(version: 2018_10_08_053117) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "name", null: false
    t.string "type", null: false
    t.jsonb "resource_parameters", default: {}, null: false
    t.datetime "started_at", precision: 3, null: false
    t.datetime "finished_at", precision: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "started_at"], name: "index_events_on_name_and_started_at", order: :desc
    t.index ["resource_id"], name: "index_events_on_resource_id"
  end

  create_table "resources", force: :cascade do |t|
    t.integer "resource_id", null: false
    t.integer "product_id", null: false
    t.integer "product_instance_id", null: false
    t.integer "client_id", null: false
    t.integer "partner_id", null: false
    t.string "kind", null: false
    t.datetime "deleted_at"
    t.datetime "originally_created_at", precision: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_name"
    t.index ["client_id"], name: "index_resources_on_client_id"
    t.index ["partner_id"], name: "index_resources_on_partner_id"
    t.index ["product_id"], name: "index_resources_on_product_id"
    t.index ["product_instance_id"], name: "index_resources_on_product_instance_id"
    t.index ["resource_id"], name: "index_resources_on_resource_id", unique: true
  end

  create_table "usages", force: :cascade do |t|
    t.integer "resource_id"
    t.jsonb "chargable", default: {}, null: false
    t.datetime "period_start", precision: 3, null: false
    t.datetime "period_end", precision: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_id", "period_start", "period_end"], name: "uniq_payload_period_per_resource", unique: true
    t.index ["resource_id"], name: "index_usages_on_resource_id"
  end

end
