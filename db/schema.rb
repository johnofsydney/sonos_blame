# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_03_102435) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "top_artists", force: :cascade do |t|
    t.string "artist"
    t.string "artist_id"
    t.string "timeframe"
    t.bigint "user_id", null: false
    t.integer "score"
    t.index ["user_id"], name: "index_top_artists_on_user_id"
  end

  create_table "top_tracks", force: :cascade do |t|
    t.string "artist"
    t.string "album"
    t.string "track"
    t.integer "popularity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.string "timeframe"
    t.string "track_id"
    t.integer "mode"
    t.integer "time_signature"
    t.float "acousticness"
    t.float "danceability"
    t.float "energy"
    t.float "instrumentalness"
    t.float "valence"
    t.float "tempo"
    t.string "artist_id"
    t.index ["user_id"], name: "index_top_tracks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "top_artists", "users"
  add_foreign_key "top_tracks", "users"
end
