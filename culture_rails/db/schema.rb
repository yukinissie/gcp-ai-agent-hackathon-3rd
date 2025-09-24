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

ActiveRecord::Schema[8.0].define(version: 2025_09_24_032954) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "article_id", null: false
    t.integer "activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at", precision: nil
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
    t.integer "tags_count"
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

  create_table "ingredients", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.json "llm_payload", default: {}, null: false
    t.json "ui_data", default: {}, null: false
    t.integer "total_interactions", default: 0, null: false
    t.decimal "diversity_score", precision: 5, scale: 3, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["total_interactions"], name: "index_ingredients_on_total_interactions"
    t.index ["updated_at"], name: "index_ingredients_on_updated_at"
    t.index ["user_id"], name: "index_ingredients_on_user_id", unique: true
    t.check_constraint "diversity_score >= 0.0 AND diversity_score <= 1.0", name: "check_diversity_score_range"
    t.check_constraint "total_interactions >= 0", name: "check_total_interactions_positive"
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

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "tag_search_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.jsonb "article_ids", default: [], null: false
    t.datetime "searched_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_ids"], name: "index_tag_search_histories_on_article_ids", using: :gin
    t.index ["searched_at"], name: "index_tag_search_histories_on_searched_at"
    t.index ["user_id"], name: "index_tag_search_histories_on_user_id"
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
  add_foreign_key "ingredients", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "tag_search_histories", "users"
  add_foreign_key "user_credentials", "users"
end
