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

ActiveRecord::Schema[8.0].define(version: 2025_04_24_055200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "status"
    t.integer "current_player_id"
    t.jsonb "board_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "moves", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "player_id", null: false
    t.jsonb "from_position"
    t.jsonb "to_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["player_id"], name: "index_moves_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "tafl_games", force: :cascade do |t|
    t.string "status"
    t.string "current_turn"
    t.json "board"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tafl_moves", force: :cascade do |t|
    t.bigint "tafl_game_id", null: false
    t.integer "from_row"
    t.integer "from_col"
    t.integer "to_row"
    t.integer "to_col"
    t.string "piece_type"
    t.json "captured_pieces"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tafl_game_id"], name: "index_tafl_moves_on_tafl_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "moves", "games"
  add_foreign_key "moves", "players"
  add_foreign_key "players", "games"
  add_foreign_key "players", "users"
  add_foreign_key "tafl_moves", "tafl_games"
end
