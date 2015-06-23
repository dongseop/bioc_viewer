# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150623033047) do

  create_table "documents", force: :cascade do |t|
    t.text     "xml",        limit: 4294967295
    t.integer  "version",    limit: 4,          default: 0, null: false
    t.integer  "user_id",    limit: 4
    t.integer  "project_id", limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "source",     limit: 255
    t.string   "d_date",     limit: 255
    t.string   "key",        limit: 255
    t.string   "doc_id",     limit: 255
  end

  add_index "documents", ["project_id"], name: "index_documents_on_project_id", using: :btree
  add_index "documents", ["user_id"], name: "index_documents_on_user_id", using: :btree

  create_table "project_users", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "project_id", limit: 4
    t.string   "priv",       limit: 255, default: "r", null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "project_users", ["project_id"], name: "index_project_users_on_project_id", using: :btree
  add_index "project_users", ["user_id"], name: "index_project_users_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "title",           limit: 255,               null: false
    t.integer  "user_id",         limit: 4
    t.text     "description",     limit: 65535
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "documents_count", limit: 4,     default: 0
  end

  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

  create_table "revisions", force: :cascade do |t|
    t.integer  "document_id", limit: 4
    t.integer  "user_id",     limit: 4
    t.string   "comment",     limit: 1000
    t.text     "xml",         limit: 4294967295, null: false
    t.integer  "version",     limit: 4,          null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "revisions", ["document_id"], name: "index_revisions_on_document_id", using: :btree
  add_index "revisions", ["user_id"], name: "index_revisions_on_user_id", using: :btree

  create_table "temp_documents", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "document_id", limit: 4
    t.text     "xml",         limit: 4294967295, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "temp_documents", ["document_id"], name: "index_temp_documents_on_document_id", using: :btree
  add_index "temp_documents", ["user_id"], name: "index_temp_documents_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 100, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "name",                   limit: 255, default: "", null: false
    t.string   "phone",                  limit: 255
    t.string   "affiliation",            limit: 255
    t.string   "reset_password_token",   limit: 100
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "documents", "projects"
  add_foreign_key "documents", "users"
  add_foreign_key "project_users", "projects"
  add_foreign_key "project_users", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "revisions", "documents"
  add_foreign_key "revisions", "users"
  add_foreign_key "temp_documents", "documents"
  add_foreign_key "temp_documents", "users"
end
