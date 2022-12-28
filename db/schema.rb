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

ActiveRecord::Schema.define(version: 2020_11_08_113007) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_api_keys_on_name", unique: true
  end

  create_table "approvals", force: :cascade do |t|
    t.uuid "role_id"
    t.uuid "user_id"
    t.uuid "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_approvals_on_author_id"
    t.index ["role_id", "user_id"], name: "index_approvals_on_role_id_and_user_id", unique: true
    t.index ["role_id"], name: "index_approvals_on_role_id"
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "archives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.date "expiry_on"
    t.text "note", default: ""
    t.bigint "quota", default: 1073741824
    t.uuid "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_archives_on_author_id"
    t.index ["expiry_on"], name: "index_archives_on_expiry_on"
    t.index ["name"], name: "index_archives_on_name", unique: true
  end

  create_table "archivization_types", force: :cascade do |t|
    t.string "name"
    t.string "activities", default: [], array: true
    t.boolean "need_more_privilage", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_archivization_types_on_name"
  end

  create_table "archivizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "archive_id"
    t.uuid "group_id"
    t.bigint "archivization_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archive_id", "group_id", "archivization_type_id"], name: "archivizations_archive_id_group_id_archivization_type_id_idx", unique: true
    t.index ["archive_id"], name: "index_archivizations_on_archive_id"
    t.index ["archivization_type_id"], name: "index_archivizations_on_archivization_type_id"
    t.index ["group_id"], name: "index_archivizations_on_group_id"
  end

  create_table "component_hierarchies", id: false, force: :cascade do |t|
    t.uuid "ancestor_id", null: false
    t.uuid "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "component_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "component_desc_idx"
  end

  create_table "components", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "component_file"
    t.string "file_content_type"
    t.string "file_size"
    t.string "name"
    t.string "name_if_folder"
    t.uuid "parent_id"
    t.text "note", default: ""
    t.string "componentable_type"
    t.uuid "componentable_id"
    t.uuid "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "for_simple_download", default: -> { "gen_random_uuid()" }
    t.index ["author_id"], name: "index_components_on_author_id"
    t.index ["componentable_type", "componentable_id"], name: "index_components_on_componentable_type_and_componentable_id"
    t.index ["name"], name: "index_components_on_name"
    t.index ["name_if_folder"], name: "index_components_on_name_if_folder"
  end

  create_table "groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "note", default: ""
    t.uuid "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_groups_on_author_id"
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.uuid "group_id"
    t.uuid "user_id"
    t.uuid "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_members_on_author_id"
    t.index ["group_id", "user_id"], name: "index_members_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_members_on_group_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "activities", default: [], array: true
    t.text "note", default: ""
    t.uuid "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_roles_on_author_id"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "wso2is_userid"
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "user_name"
    t.boolean "csu_confirmed"
    t.datetime "csu_confirmed_at"
    t.string "csu_confirmed_by"
    t.string "session_index"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.text "note", default: ""
    t.uuid "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_users_on_author_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["session_index"], name: "index_users_on_session_index"
  end

  create_table "works", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "trackable_type"
    t.uuid "trackable_id"
    t.uuid "author_id"
    t.string "action"
    t.string "url"
    t.text "parameters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_works_on_author_id"
    t.index ["trackable_type", "trackable_id"], name: "index_works_on_trackable_type_and_trackable_id"
  end

  add_foreign_key "approvals", "roles"
  add_foreign_key "approvals", "users"
  add_foreign_key "approvals", "users", column: "author_id"
  add_foreign_key "archives", "users", column: "author_id"
  add_foreign_key "archivizations", "archives"
  add_foreign_key "archivizations", "archivization_types"
  add_foreign_key "archivizations", "groups"
  add_foreign_key "components", "users", column: "author_id"
  add_foreign_key "groups", "users", column: "author_id"
  add_foreign_key "members", "groups"
  add_foreign_key "members", "users"
  add_foreign_key "members", "users", column: "author_id"
  add_foreign_key "roles", "users", column: "author_id"
  add_foreign_key "works", "users", column: "author_id"
end
