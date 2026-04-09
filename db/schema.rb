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

ActiveRecord::Schema[8.1].define(version: 2026_04_09_154322) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "region_id", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_customers_on_lower_name", unique: true
    t.index ["region_id"], name: "index_customers_on_region_id"
    t.check_constraint "name::text <> ''::text", name: "customers_name_not_empty"
  end

  create_table "quotes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.decimal "normalized_rate", precision: 8, scale: 6, null: false
    t.decimal "rate", precision: 8, scale: 6, null: false
    t.bigint "supplier_id", null: false
    t.boolean "tax_included", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "supplier_id"], name: "index_quotes_on_customer_id_and_supplier_id", unique: true
    t.index ["customer_id"], name: "index_quotes_on_customer_id"
    t.index ["supplier_id"], name: "index_quotes_on_supplier_id"
    t.check_constraint "normalized_rate > 0::numeric", name: "quotes_normalized_rate_positive"
    t.check_constraint "rate > 0::numeric", name: "quotes_rate_positive"
  end

  create_table "regions", force: :cascade do |t|
    t.string "abbreviation", null: false
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.decimal "tax_rate", precision: 5, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["abbreviation", "country_code"], name: "index_regions_on_abbreviation_and_country_code", unique: true
    t.check_constraint "abbreviation::text <> ''::text", name: "regions_abbreviation_not_empty"
    t.check_constraint "country_code::text ~ '^[A-Z]{2}$'::text", name: "regions_country_code_format"
    t.check_constraint "tax_rate >= 0::numeric", name: "regions_tax_rate_non_negative"
  end

  create_table "suppliers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_suppliers_on_lower_name", unique: true
    t.check_constraint "name::text <> ''::text", name: "suppliers_name_not_empty"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customers", "regions"
  add_foreign_key "quotes", "customers"
  add_foreign_key "quotes", "suppliers"
end
