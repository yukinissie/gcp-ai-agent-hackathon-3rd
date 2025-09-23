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
    t.index ["content_format"], name: "index_articles_on_content_format"
    t.index ["published", "published_at"], name: "index_articles_on_published_and_published_at"
    t.index ["published"], name: "index_articles_on_published"
    t.index ["published_at"], name: "index_articles_on_published_at"
  end

  create_table "mastra_evals", id: false, force: :cascade do |t|
    t.text "input", null: false
    t.text "output", null: false
    t.jsonb "result", null: false
    t.text "agent_name", null: false
    t.text "metric_name", null: false
    t.text "instructions", null: false
    t.jsonb "test_info"
    t.text "global_run_id", null: false
    t.text "run_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "createdAt", precision: nil
    t.timestamptz "created_atZ", default: -> { "now()" }
    t.timestamptz "createdAtZ", default: -> { "now()" }
    t.index ["agent_name", "created_at"], name: "public_mastra_evals_agent_name_created_at_idx", order: { created_at: :desc }
  end

  create_table "mastra_messages", id: :text, force: :cascade do |t|
    t.text "thread_id", null: false
    t.text "content", null: false
    t.text "role", null: false
    t.text "type", null: false
    t.datetime "createdAt", precision: nil, null: false
    t.text "resourceId"
    t.timestamptz "createdAtZ", default: -> { "now()" }
    t.index ["thread_id", "createdAt"], name: "public_mastra_messages_thread_id_createdat_idx", order: { createdAt: :desc }
  end

  create_table "mastra_resources", id: :text, force: :cascade do |t|
    t.text "workingMemory"
    t.jsonb "metadata"
    t.datetime "createdAt", precision: nil, null: false
    t.datetime "updatedAt", precision: nil, null: false
    t.timestamptz "createdAtZ", default: -> { "now()" }
    t.timestamptz "updatedAtZ", default: -> { "now()" }
  end

  create_table "mastra_scorers", id: :text, force: :cascade do |t|
    t.text "scorerId", null: false
    t.text "traceId"
    t.text "runId", null: false
    t.jsonb "scorer", null: false
    t.jsonb "preprocessStepResult"
    t.jsonb "extractStepResult"
    t.jsonb "analyzeStepResult"
    t.float "score", null: false
    t.text "reason"
    t.jsonb "metadata"
    t.text "preprocessPrompt"
    t.text "extractPrompt"
    t.text "generateScorePrompt"
    t.text "generateReasonPrompt"
    t.text "analyzePrompt"
    t.text "reasonPrompt"
    t.jsonb "input", null: false
    t.jsonb "output", null: false
    t.jsonb "additionalContext"
    t.jsonb "runtimeContext"
    t.text "entityType"
    t.jsonb "entity"
    t.text "entityId"
    t.text "source", null: false
    t.text "resourceId"
    t.text "threadId"
    t.datetime "createdAt", precision: nil, null: false
    t.datetime "updatedAt", precision: nil, null: false
    t.timestamptz "createdAtZ", default: -> { "now()" }
    t.timestamptz "updatedAtZ", default: -> { "now()" }
  end

  create_table "mastra_threads", id: :text, force: :cascade do |t|
    t.text "resourceId", null: false
    t.text "title", null: false
    t.text "metadata"
    t.datetime "createdAt", precision: nil, null: false
    t.datetime "updatedAt", precision: nil, null: false
    t.timestamptz "createdAtZ", default: -> { "now()" }
    t.timestamptz "updatedAtZ", default: -> { "now()" }
    t.index ["resourceId", "createdAt"], name: "public_mastra_threads_resourceid_createdat_idx", order: { createdAt: :desc }
  end

  create_table "mastra_traces", id: :text, force: :cascade do |t|
    t.text "parentSpanId"
    t.text "name", null: false
    t.text "traceId", null: false
    t.text "scope", null: false
    t.integer "kind", null: false
    t.jsonb "attributes"
    t.jsonb "status"
    t.jsonb "events"
    t.jsonb "links"
    t.text "other"
    t.bigint "startTime", null: false
    t.bigint "endTime", null: false
    t.datetime "createdAt", precision: nil, null: false
    t.timestamptz "createdAtZ", default: -> { "now()" }
    t.index ["name", "startTime"], name: "public_mastra_traces_name_starttime_idx", order: { startTime: :desc }
  end

  create_table "mastra_workflow_snapshot", id: false, force: :cascade do |t|
    t.text "workflow_name", null: false
    t.text "run_id", null: false
    t.text "resourceId"
    t.text "snapshot", null: false
    t.datetime "createdAt", precision: nil, null: false
    t.datetime "updatedAt", precision: nil, null: false
    t.timestamptz "createdAtZ", default: -> { "now()" }
    t.timestamptz "updatedAtZ", default: -> { "now()" }

    t.unique_constraint ["workflow_name", "run_id"], name: "public_mastra_workflow_snapshot_workflow_name_run_id_key"
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
  add_foreign_key "sessions", "users"
  add_foreign_key "user_credentials", "users"
end
