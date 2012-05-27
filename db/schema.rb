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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120526234324) do

  create_table "categories", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "webkey",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "images", :force => true do |t|
    t.integer  "reviewable_id"
    t.text     "url",           :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "caption"
  end

  create_table "manufacturers", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "webkey",       :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "official_url"
  end

  create_table "prices", :force => true do |t|
    t.integer  "reviewable_id", :null => false
    t.string   "url",           :null => false
    t.float    "amount",        :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "ratings", :force => true do |t|
    t.integer  "reviewable_id", :null => false
    t.string   "url",           :null => false
    t.string   "raw_value",     :null => false
    t.float    "value",         :null => false
    t.integer  "num_reviews",   :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "reviewables", :force => true do |t|
    t.string   "type",                                                               :null => false
    t.integer  "category_id",                                                        :null => false
    t.integer  "manufacturer_id"
    t.string   "name",                                                               :null => false
    t.string   "full_name",                                                          :null => false
    t.string   "webkey",                                                             :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.text     "summary"
    t.text     "specs",              :default => "--- {}\n"
    t.integer  "num_reviews"
    t.text     "content_urls",       :default => "--- !ruby/object:Set\nhash: {}\n"
    t.text     "official_urls",      :default => "--- !ruby/object:Set\nhash: {}\n"
    t.text     "mention_urls",       :default => "--- !ruby/object:Set\nhash: {}\n"
    t.date     "market_released_on"
    t.float    "aggregated_score"
    t.boolean  "is_chipset",         :default => false,                              :null => false
    t.integer  "state",              :default => 0
    t.integer  "chipset_id"
  end

  create_table "urls", :force => true do |t|
    t.string   "url",                         :null => false
    t.text     "content_html",                :null => false
    t.string   "content_md5",                 :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "state",        :default => 0
  end

end
