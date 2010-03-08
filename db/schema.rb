# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100305161926) do

  create_table "categories", :force => true do |t|
    t.string "name", :limit => 200, :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "ragionesociale"
    t.string   "indirizzo"
    t.string   "comune"
    t.string   "cap"
    t.string   "prov"
    t.string   "coordinatebancarie"
    t.string   "telefono"
    t.string   "partitaiva"
    t.string   "codicefiscale"
    t.string   "email"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo",               :limit => 150
    t.string   "rea",                :limit => 200
    t.string   "web",                :limit => 200
  end

  create_table "customers", :force => true do |t|
    t.string   "ragionesociale",                    :null => false
    t.string   "partitaiva",         :limit => 11,  :null => false
    t.string   "codicefiscale",      :limit => 16
    t.string   "indirizzo"
    t.string   "civico",             :limit => 15
    t.string   "comune"
    t.string   "cap",                :limit => 6
    t.string   "prov",               :limit => 2
    t.text     "note"
    t.string   "telefono",           :limit => 25
    t.string   "fax",                :limit => 25
    t.string   "email",              :limit => 150
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "coordinatebancarie"
  end

  create_table "documents", :force => true do |t|
    t.integer  "project_id",                :null => false
    t.string   "doc",        :limit => 400
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "doctype",    :limit => 20
  end

  create_table "invoiceitems", :force => true do |t|
    t.integer  "invoice_id",                                    :null => false
    t.decimal  "quantity",       :precision => 10, :scale => 2
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "category_id"
    t.integer  "projectitem_id",                                :null => false
  end

  create_table "invoices", :force => true do |t|
    t.integer  "project_id",                                         :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.integer  "budget_id"
    t.datetime "updated_at"
    t.string   "code",             :limit => 20
    t.integer  "year"
    t.string   "title",            :limit => 150
    t.integer  "customer_id"
    t.integer  "paymentmethod_id"
    t.string   "bank",             :limit => 100
    t.string   "delivery",         :limit => 100
    t.text     "people"
    t.text     "notes"
    t.float    "discount"
    t.integer  "vat"
    t.integer  "document_id"
    t.integer  "pricing_id"
    t.boolean  "payed",                           :default => false, :null => false
    t.date     "payed_date"
    t.boolean  "deleted",                         :default => false, :null => false
    t.integer  "projectitem_id",                  :default => 0,     :null => false
    t.integer  "expires"
  end

  create_table "orderitems", :force => true do |t|
    t.integer  "order_id",                                      :null => false
    t.decimal  "quantity",       :precision => 10, :scale => 2
    t.float    "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "projectitem_id",                                :null => false
  end

  create_table "orders", :force => true do |t|
    t.integer  "project_id",                                       :null => false
    t.integer  "user_id"
    t.integer  "budget_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",              :limit => 150
    t.string   "delivery",           :limit => 100
    t.integer  "vat"
    t.integer  "supplier_id"
    t.integer  "paymentmethod_id"
    t.text     "people"
    t.text     "notes"
    t.integer  "document_id"
    t.integer  "received_invoice",                  :default => 0
    t.float    "amount_invoice"
    t.date     "expires_invoice"
    t.integer  "payed_invoice",                     :default => 0
    t.date     "payed_invoice_date"
    t.boolean  "deleted",                                          :null => false
    t.integer  "year"
    t.string   "code",               :limit => 20
  end

  create_table "paymentmethods", :force => true do |t|
    t.string "paymentmethod", :limit => 100
  end

  create_table "pricingitems", :force => true do |t|
    t.integer  "pricing_id",                                                   :null => false
    t.decimal  "quantity",       :precision => 10, :scale => 2
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "category_id"
    t.integer  "projectitem_id",                                :default => 0
    t.integer  "display_order"
  end

  create_table "pricings", :force => true do |t|
    t.integer  "project_id",                                                                      :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",             :limit => 20
    t.integer  "year"
    t.string   "title",            :limit => 150
    t.integer  "customer_id"
    t.integer  "paymentmethod_id"
    t.string   "invoicing",        :limit => 100
    t.string   "delivery",         :limit => 100
    t.text     "people"
    t.text     "notes"
    t.integer  "document_id"
    t.integer  "approved",                                                       :default => 0
    t.datetime "approval_date"
    t.integer  "code_abs"
    t.decimal  "discount",                        :precision => 10, :scale => 4, :default => 0.0
  end

  create_table "proceeds", :force => true do |t|
    t.integer  "project_id", :null => false
    t.integer  "user_id"
    t.integer  "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount"
    t.date     "date"
  end

  create_table "projectitems", :force => true do |t|
    t.integer  "project_id"
    t.decimal  "quantity",      :precision => 10, :scale => 2
    t.decimal  "cost",          :precision => 10, :scale => 4
    t.decimal  "price",         :precision => 10, :scale => 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.text     "description"
    t.integer  "display_order"
  end

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.date     "start"
    t.date     "end"
    t.text     "note"
    t.integer  "customer_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
    t.string   "contact",     :limit => 150
    t.string   "code",        :limit => 10
    t.string   "year",        :limit => 4
    t.integer  "user_id",                    :null => false
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"
  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"

  create_table "status", :force => true do |t|
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suppliers", :force => true do |t|
    t.string   "ragionesociale",                    :null => false
    t.string   "partitaiva",         :limit => 11,  :null => false
    t.string   "codicefiscale",      :limit => 16
    t.string   "indirizzo"
    t.string   "civico",             :limit => 15
    t.string   "comune"
    t.string   "cap",                :limit => 6
    t.string   "prov",               :limit => 2
    t.text     "note"
    t.string   "telefono",           :limit => 25
    t.string   "fax",                :limit => 25
    t.string   "email",              :limit => 150
    t.text     "coordinatebancarie"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "paymentmethod_id"
  end

  create_table "timesheet", :force => true do |t|
    t.datetime "date",       :null => false
    t.float    "hours",      :null => false
    t.integer  "project_id", :null => false
    t.integer  "user_id",    :null => false
    t.text     "notes"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                                                  :default => "'NULL'"
    t.string   "email",                                                                  :default => "'NULL'"
    t.string   "crypted_password",          :limit => 40,                                :default => "'NULL'"
    t.string   "salt",                      :limit => 40,                                :default => "'NULL'"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",                                                         :default => "'NULL'"
    t.datetime "remember_token_expires_at"
    t.boolean  "active"
    t.string   "nominativo",                :limit => 20
    t.integer  "hourly_cost",               :limit => 10, :precision => 10, :scale => 0, :default => 0
  end

  create_table "xp_proc", :id => false, :force => true do |t|
    t.string "view_name",  :limit => 20
    t.string "param_list"
    t.text   "xSQL"
    t.string "def_param"
    t.string "opt_param"
    t.text   "comment"
  end

end
