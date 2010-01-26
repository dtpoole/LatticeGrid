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

ActiveRecord::Schema.define(:version => 20100125214256) do

  create_table "abstracts", :force => true do |t|
    t.text     "endnote_citation"
    t.text     "abstract"
    t.text     "authors"
    t.text     "full_authors"
    t.boolean  "is_first_author_investigator", :default => false
    t.boolean  "is_last_author_investigator",  :default => false
    t.text     "title"
    t.string   "journal_abbreviation"
    t.string   "journal"
    t.string   "volume"
    t.string   "issue"
    t.string   "pages"
    t.string   "year"
    t.date     "publication_date"
    t.string   "publication_type"
    t.date     "electronic_publication_date"
    t.date     "deposited_date"
    t.string   "status"
    t.string   "publication_status"
    t.string   "pubmed"
    t.string   "issn"
    t.string   "isbn"
    t.integer  "citation_cnt",                 :default => 0
    t.datetime "citation_last_get_at"
    t.string   "citation_url"
    t.string   "url"
    t.text     "mesh"
    t.datetime "created_at"
    t.integer  "created_id"
    t.string   "created_ip"
    t.datetime "updated_at"
    t.integer  "updated_id"
    t.string   "updated_ip"
    t.datetime "deleted_at"
    t.integer  "deleted_id"
    t.string   "deleted_ip"
    t.string   "pmcid"
    t.string   "editors"
    t.string   "publisher"
    t.string   "publisher_location"
    t.string   "source"
    t.string   "source_id"
  end

  create_table "investigator_abstracts", :force => true do |t|
    t.integer  "abstract_id",                        :null => false
    t.integer  "investigator_id",                    :null => false
    t.boolean  "is_first_author", :default => false, :null => false
    t.boolean  "is_last_author",  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "investigator_appointments", :force => true do |t|
    t.integer  "organizational_unit_id", :null => false
    t.integer  "investigator_id",        :null => false
    t.string   "type"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "investigator_colleagues", :force => true do |t|
    t.integer  "investigator_id"
    t.integer  "colleague_id"
    t.integer  "mesh_tags_cnt"
    t.float    "mesh_tags_ic"
    t.integer  "publication_cnt",  :default => 0
    t.text     "publication_list"
    t.boolean  "in_same_program",  :default => false
    t.integer  "proposal_cnt",     :default => 0
    t.text     "proposal_list"
    t.integer  "study_cnt",        :default => 0
    t.text     "study_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "investigator_colleagues", ["colleague_id", "investigator_id", "mesh_tags_ic"], :name => "by_colleague_mesh_ic"
  add_index "investigator_colleagues", ["colleague_id", "investigator_id", "publication_cnt"], :name => "by_colleague_pubs"
  add_index "investigator_colleagues", ["colleague_id", "investigator_id"], :name => "by_colleague_investigator", :unique => true

  create_table "investigator_proposals", :force => true do |t|
    t.date     "submission_date"
    t.date     "award_date"
    t.boolean  "is_awarded",      :default => false
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "investigator_id",                    :null => false
    t.integer  "proposal_id",                        :null => false
  end

  create_table "investigator_studies", :force => true do |t|
    t.string   "status"
    t.date     "approval_date"
    t.date     "completion_date"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "investigator_id", :null => false
    t.integer  "study_id",        :null => false
  end

  create_table "investigators", :force => true do |t|
    t.string   "username",                                                                    :null => false
    t.string   "last_name",                                                                   :null => false
    t.string   "first_name",                                                                  :null => false
    t.string   "middle_name"
    t.string   "email"
    t.string   "degrees"
    t.string   "suffix"
    t.integer  "employee_id"
    t.string   "title"
    t.integer  "home_department_id"
    t.string   "campus"
    t.string   "appointment_type"
    t.string   "appointment_track"
    t.string   "appointment_basis"
    t.string   "pubmed_search_name"
    t.boolean  "pubmed_limit_to_institution",                              :default => false
    t.integer  "num_first_pubs_last_five_years",                           :default => 0
    t.integer  "num_last_pubs_last_five_years",                            :default => 0
    t.integer  "total_pubs_last_five_years",                               :default => 0
    t.integer  "num_intraunit_collaborators_last_five_years",              :default => 0
    t.integer  "num_extraunit_collaborators_last_five_years",              :default => 0
    t.integer  "num_first_pubs",                                           :default => 0
    t.integer  "num_last_pubs",                                            :default => 0
    t.integer  "total_pubs",                                               :default => 0
    t.integer  "num_intraunit_collaborators",                              :default => 0
    t.integer  "num_extraunit_collaborators",                              :default => 0
    t.date     "last_pubmed_search"
    t.string   "mailcode"
    t.text     "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.string   "business_phone"
    t.string   "home_phone"
    t.string   "lab_phone"
    t.string   "fax"
    t.string   "pager"
    t.string   "ssn",                                         :limit => 9
    t.string   "sex",                                         :limit => 1
    t.date     "birth_date"
    t.date     "nu_start_date"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "weekly_hours_min",                                         :default => 35
    t.datetime "last_successful_login"
    t.datetime "last_login_failure"
    t.integer  "consecutive_login_failures",                               :default => 0
    t.string   "password"
    t.datetime "password_changed_at"
    t.integer  "password_changed_id"
    t.string   "password_changed_ip"
    t.integer  "created_id"
    t.string   "created_ip"
    t.integer  "updated_id"
    t.string   "updated_ip"
    t.datetime "deleted_at"
    t.integer  "deleted_id"
    t.string   "deleted_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "investigators", ["username"], :name => "index_investigators_on_username", :unique => true

  create_table "journals", :force => true do |t|
    t.string   "journal_name"
    t.string   "journal_abbreviation"
    t.string   "jcr_journal_abbreviation"
    t.string   "issn"
    t.integer  "score_year"
    t.integer  "total_cites"
    t.float    "impact_factor"
    t.float    "impact_factor_five_year"
    t.float    "immediacy_index"
    t.integer  "total_articles"
    t.float    "eigenfactor_score"
    t.float    "article_influence_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "load_dates", :force => true do |t|
    t.datetime "load_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "load_dates", ["load_date"], :name => "index_load_dates_on_load_date", :unique => true

  create_table "organization_abstracts", :force => true do |t|
    t.integer  "organizational_unit_id", :null => false
    t.integer  "abstract_id",            :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizational_units", :force => true do |t|
    t.string   "name",                                       :null => false
    t.string   "search_name"
    t.string   "abbreviation"
    t.string   "campus"
    t.string   "organization_url"
    t.string   "type",                                       :null => false
    t.string   "organization_classification"
    t.string   "organization_phone"
    t.integer  "department_id",               :default => 0, :null => false
    t.integer  "division_id",                 :default => 0
    t.integer  "member_count",                :default => 0
    t.integer  "appointment_count",           :default => 0
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "children_count",              :default => 0
    t.integer  "sort_order",                  :default => 1
    t.integer  "parent_id"
    t.integer  "depth",                       :default => 0
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizational_units", ["department_id", "division_id"], :name => "index_organizational_units_on_department_id_and_division_id", :unique => true

  create_table "proposals", :force => true do |t|
    t.text     "title"
    t.text     "abstract"
    t.text     "authors"
    t.string   "agency"
    t.date     "submission_date"
    t.date     "award_date"
    t.boolean  "is_awarded",      :default => false
    t.string   "award_mechanism"
    t.string   "status"
    t.string   "url"
    t.integer  "created_id"
    t.string   "created_ip"
    t.integer  "updated_id"
    t.string   "updated_ip"
    t.datetime "deleted_at"
    t.integer  "deleted_id"
    t.string   "deleted_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "studies", :force => true do |t|
    t.text     "title"
    t.text     "abstract"
    t.string   "sponsor"
    t.string   "nct_id"
    t.integer  "accrual_goal"
    t.date     "approval_date"
    t.date     "closure_date"
    t.date     "completion_date"
    t.boolean  "is_awarded",      :default => false
    t.string   "award_mechanism"
    t.string   "status"
    t.string   "url"
    t.integer  "created_id"
    t.string   "created_ip"
    t.integer  "updated_id"
    t.string   "updated_ip"
    t.datetime "deleted_at"
    t.integer  "deleted_id"
    t.string   "deleted_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.float    "information_content", :default => 0.0
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
