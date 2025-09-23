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

ActiveRecord::Schema[8.0].define(version: 2025_09_23_061748) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "article_id", null: false
    t.integer "activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type"], name: "index_activities_on_activity_type"
    t.index ["article_id", "activity_type", "created_at"], name: "idx_on_article_id_activity_type_created_at_2a8adb508a"
    t.index ["article_id"], name: "index_activities_on_article_id"
    t.index ["user_id", "article_id", "activity_type", "created_at"], name: "index_activities_on_user_article_type_time"
    t.index ["user_id", "article_id"], name: "index_activities_on_user_id_and_article_id", unique: true
    t.index ["user_id", "created_at"], name: "index_activities_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

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
    t.bigint "feed_id", comment: "RSS由来の記事の場合のフィード参照"
    t.string "source_type", default: "manual", null: false, comment: "記事の作成元"
    t.index ["content_format"], name: "index_articles_on_content_format"
    t.index ["feed_id", "created_at"], name: "index_articles_on_feed_id_and_created_at", comment: "フィード別記事一覧用"
    t.index ["feed_id", "source_url"], name: "index_articles_on_feed_and_source_url_for_rss", unique: true, where: "(((source_type)::text = 'rss'::text) AND (source_url IS NOT NULL))", comment: "RSS記事の重複防止"
    t.index ["feed_id"], name: "index_articles_on_feed_id"
    t.index ["published", "published_at"], name: "index_articles_on_published_and_published_at"
    t.index ["published"], name: "index_articles_on_published"
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["source_type"], name: "index_articles_on_source_type", comment: "ソース種別での絞り込み用"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "title", null: false, comment: "フィードのタイトル"
    t.string "endpoint", null: false, comment: "RSS/AtomフィードのURL"
    t.string "status", default: "active", null: false, comment: "フィードの状態"
    t.datetime "last_fetched_at", comment: "最後に取得した日時"
    t.text "last_error", comment: "最後のエラーメッセージ"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_feeds_on_created_at", comment: "作成日時でのソート用"
    t.index ["endpoint"], name: "index_feeds_on_endpoint", unique: true, comment: "エンドポイントの一意性"
    t.index ["last_fetched_at"], name: "index_feeds_on_last_fetched_at", comment: "取得日時でのソート用"
    t.index ["status"], name: "index_feeds_on_status", comment: "状態での絞り込み用"
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

  add_foreign_key "activities", "articles"
  add_foreign_key "activities", "users"
  add_foreign_key "article_taggings", "articles"
  add_foreign_key "article_taggings", "tags"
  add_foreign_key "articles", "feeds"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_credentials", "users"
end
