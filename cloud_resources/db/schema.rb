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

ActiveRecord::Schema.define(version: 20181225090352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "cloud_spaces", force: :cascade do |t|
    t.integer "location_id"
    t.integer "cloud_id"
    t.string "cloud_name"
    t.string "cloud_status"
    t.string "cloud_public_ip_address"
    t.integer "partner_id"
    t.integer "client_id"
    t.integer "product_id"
    t.integer "product_instance_id"
    t.integer "current_event_id"
    t.string "name"
    t.string "description"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "disks", force: :cascade do |t|
    t.integer "machine_id"
    t.integer "cloud_id"
    t.string "cloud_type"
    t.string "cloud_status"
    t.integer "partner_id"
    t.integer "client_id"
    t.integer "product_id"
    t.integer "product_instance_id"
    t.integer "current_event_id"
    t.string "name"
    t.string "description"
    t.string "type"
    t.string "state"
    t.integer "size"
    t.integer "iops_sec"
    t.integer "bytes_sec"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "events", force: :cascade do |t|
    t.integer "resource_id"
    t.string "resource_type"
    t.string "name"
    t.hstore "params"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "delivered_at"
  end

  create_table "images", force: :cascade do |t|
    t.integer "location_id"
    t.integer "cloud_id"
    t.string "cloud_name"
    t.string "cloud_type"
    t.string "cloud_status"
    t.integer "partner_id"
    t.integer "client_id"
    t.integer "product_id"
    t.integer "product_instance_id"
    t.integer "current_event_id"
    t.string "name"
    t.string "description"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "locations", force: :cascade do |t|
    t.string "code"
    t.integer "gid"
    t.string "url"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "machines", force: :cascade do |t|
    t.integer "cloud_id"
    t.integer "cloud_space_id"
    t.integer "image_id"
    t.integer "partner_id"
    t.integer "client_id"
    t.integer "product_id"
    t.integer "product_instance_id"
    t.integer "current_event_id"
    t.string "name"
    t.string "description"
    t.string "state"
    t.string "status"
    t.integer "memory"
    t.integer "vcpus"
    t.integer "boot_disk_size"
    t.string "local_ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "ssh_keys", array: true
  end

  create_table "playbooks", force: :cascade do |t|
    t.string "state"
    t.json "error_messages"
    t.json "schema"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "client_id"
    t.integer "partner_id"
    t.integer "product_id"
    t.integer "product_instance_id"
    t.integer "product_instance_job_id"
  end

  create_table "ports", force: :cascade do |t|
    t.integer "cloud_space_id"
    t.integer "machine_id"
    t.integer "cloud_id"
    t.string "cloud_local_ip"
    t.integer "cloud_local_port"
    t.string "cloud_protocol"
    t.string "cloud_public_ip"
    t.integer "cloud_public_port"
    t.integer "partner_id"
    t.integer "client_id"
    t.integer "product_id"
    t.integer "product_instance_id"
    t.string "name"
    t.string "description"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "current_event_id"
  end

  create_table "snapshots", force: :cascade do |t|
    t.integer "machine_id"
    t.integer "partner_id"
    t.integer "client_id"
    t.integer "product_id"
    t.integer "product_instance_id"
    t.string "name"
    t.string "description"
    t.string "state"
    t.string "cloud_name"
    t.integer "cloud_epoch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

end
