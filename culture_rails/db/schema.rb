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

ActiveRecord::Schema[8.0].define(version: 2025_09_21_141631) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "article_taggings", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id", "tag_id"], name: "index_article_taggings_on_article_id_and_tag_id", unique: true
    t.index ["article_id"], name: "index_article_taggings_on_article_id"
    t.index ["tag_id"], name: "index_article_taggings_on_tag_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title", null: false
    t.text "summary", null: false
    t.string "author", null: false
    t.string "source_url"
    t.string "image_url"
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content", null: false
    t.string "content_format", default: "markdown", null: false
    t.index ["content_format"], name: "index_articles_on_content_format"
    t.index ["published", "published_at"], name: "index_articles_on_published_and_published_at"
    t.index ["published"], name: "index_articles_on_published"
    t.index ["published_at"], name: "index_articles_on_published_at"
  end

  create_table "pings", force: :cascade do |t|
    t.string "message", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_tags_on_category"
    t.index ["name", "category"], name: "index_tags_on_name_and_category", unique: true
  end

  create_table "user_credentials", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_user_credentials_on_email_address", unique: true
    t.index ["user_id"], name: "index_user_credentials_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "human_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["human_id"], name: "index_users_on_human_id", unique: true
  end

  add_foreign_key "article_taggings", "articles"
  add_foreign_key "article_taggings", "tags"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_credentials", "users"
end
