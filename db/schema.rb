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

ActiveRecord::Schema.define(version: 2021_03_16_114040) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "checkbox_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "further_information"
    t.boolean "skipped", default: false
    t.index ["step_id"], name: "index_checkbox_answers_on_step_id"
  end

  create_table "currency_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.decimal "response", precision: 11, scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_currency_answers_on_step_id"
  end

  create_table "journeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "liquid_template", null: false
    t.jsonb "section_groups"
  end

  create_table "long_text_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.text "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_long_text_answers_on_step_id"
  end

  create_table "number_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.integer "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_number_answers_on_step_id"
  end

  create_table "radio_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "further_information"
    t.index ["step_id"], name: "index_radio_answers_on_step_id"
  end

  create_table "short_text_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.string "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_short_text_answers_on_step_id"
  end

  create_table "single_date_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "step_id"
    t.date "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["step_id"], name: "index_single_date_answers_on_step_id"
  end

  create_table "steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "journey_id"
    t.string "title", null: false
    t.string "help_text"
    t.string "contentful_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "body"
    t.string "contentful_model"
    t.string "primary_call_to_action_text"
    t.string "contentful_id", null: false
    t.jsonb "raw", null: false
    t.jsonb "options"
    t.boolean "hidden", default: false
    t.jsonb "additional_step_rules"
    t.string "skip_call_to_action_text"
    t.index ["journey_id"], name: "index_steps_on_journey_id"
  end

  add_foreign_key "long_text_answers", "steps", on_delete: :cascade
  add_foreign_key "radio_answers", "steps", on_delete: :cascade
  add_foreign_key "short_text_answers", "steps", on_delete: :cascade
  add_foreign_key "steps", "journeys", on_delete: :cascade
end
