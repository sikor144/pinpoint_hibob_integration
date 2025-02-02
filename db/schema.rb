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

ActiveRecord::Schema[7.1].define(version: 2024_07_10_070514) do
  create_table "webhook_events", force: :cascade do |t|
    t.string "source"
    t.string "event_name"
    t.json "payload", default: {}
    t.string "status", default: "created"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event_signature"
    t.index ["event_name"], name: "index_webhook_events_on_event_name"
    t.index ["event_signature"], name: "index_webhook_events_on_event_signature", unique: true
    t.index ["source"], name: "index_webhook_events_on_source"
    t.index ["status"], name: "index_webhook_events_on_status"
  end

end
