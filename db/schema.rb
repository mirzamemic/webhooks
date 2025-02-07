# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_06_103538) do
  create_table "customers", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "email"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_customers_on_external_id", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "type", null: false
    t.string "external_id", null: false
    t.string "name", null: false
    t.string "status", default: "pending"
    t.json "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_events_on_external_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "status", default: "unpaid"
    t.integer "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_subscriptions_on_customer_id"
    t.index ["external_id"], name: "index_subscriptions_on_external_id", unique: true
  end

  add_foreign_key "subscriptions", "customers"
end
