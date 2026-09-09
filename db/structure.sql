CREATE TABLE "companies" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "alias" text DEFAULT '[]', "active" boolean DEFAULT 1, "is_customer" boolean DEFAULT 0, "is_partner" boolean DEFAULT 0, "website" varchar, "image_url" varchar, "notes" text, "city" varchar, "state" varchar, "country" varchar, "build_level" varchar, "consulting_level" varchar, "reseller_level" varchar, "service_provider_level" varchar, "partner_level" varchar, "servicenow_url" varchar, "rss_feed_url" varchar, "servicenow_page_url" varchar, "products" text DEFAULT '[]', "services" text DEFAULT '[]', "last_fetched_at" datetime(6), "last_sitemap_check" datetime(6), "has_sitemap" boolean, "last_found_in_partner_list" datetime(6), "locked_fields" text DEFAULT '[]', "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE INDEX "index_companies_on_active" ON "companies" ("active") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_companies_on_is_customer" ON "companies" ("is_customer") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_companies_on_is_partner" ON "companies" ("is_partner") /*application='NewsJaceProRr'*/;
CREATE UNIQUE INDEX "index_companies_on_name" ON "companies" ("name") /*application='NewsJaceProRr'*/;
CREATE TABLE "knowledge_sessions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "code" varchar, "session_id" varchar, "title" varchar, "title_sort" varchar, "abstract" text, "published" varchar, "modified" datetime(6), "event_id" varchar, "participants" text, "times" text, "recording_url" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "last_seen_at" datetime(6), "url" varchar, "canceled_at" datetime(6));
CREATE UNIQUE INDEX "index_knowledge_sessions_on_session_id" ON "knowledge_sessions" ("session_id") /*application='NewsJaceProRr'*/;
CREATE TABLE "news_feeds" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar, "active" boolean DEFAULT 1, "status" varchar DEFAULT 'active', "notes" text, "image_url" varchar, "url" varchar, "default_author" varchar, "feed_type" varchar DEFAULT 'rss', "fetch_url" varchar, "last_successful_fetch" datetime(6), "last_error" text, "error_count" integer DEFAULT 0, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE INDEX "index_news_feeds_on_active" ON "news_feeds" ("active") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_news_feeds_on_feed_type" ON "news_feeds" ("feed_type") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_news_feeds_on_status" ON "news_feeds" ("status") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_news_feeds_on_title" ON "news_feeds" ("title") /*application='NewsJaceProRr'*/;
CREATE TABLE "servicenow_investments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "investment_type" varchar, "content" text, "summary" text, "url" varchar, "amount" varchar, "currency" varchar, "date" datetime(6), "people" text, "company_name" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE "servicenow_store_apps" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "source_app_id" varchar, "title" varchar, "tagline" varchar, "store_description" text, "company_name" varchar, "company_logo" varchar, "logo" varchar, "app_type" varchar, "app_sub_type" varchar, "version" varchar, "versions_data" text, "purchase_count" integer, "review_count" integer, "table_count" integer, "key_features" text, "business_challenge" text, "system_requirements" text, "supporting_media" text, "support_links" text, "support_contacts" text, "purchase_trend" text, "display_price" varchar, "landing_page" varchar, "allow_for_existing_customers" boolean, "allow_for_non_customers" boolean, "allow_on_customer_subprod" boolean, "allow_on_developer_instance" boolean, "allow_on_servicenow_instance" boolean, "allow_trial" boolean, "allow_without_license" boolean, "last_fetched_at" datetime(6), "published_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "listing_id" varchar, "featured_icon" varchar);
CREATE UNIQUE INDEX "index_servicenow_store_apps_on_source_app_id" ON "servicenow_store_apps" ("source_app_id") /*application='NewsJaceProRr'*/;
CREATE TABLE "tags" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_tags_on_name" ON "tags" ("name") /*application='NewsJaceProRr'*/;
CREATE TABLE "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar, "password_digest" varchar, "name" varchar, "link" varchar, "roles" varchar, "reset_token" varchar, "reset_token_expires_at" datetime(6));
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email") /*application='NewsJaceProRr'*/;
CREATE TABLE "knowledge_session_lists" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "knowledge_session_id" integer NOT NULL, "user_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b722b0f55a"
FOREIGN KEY ("knowledge_session_id")
  REFERENCES "knowledge_sessions" ("id")
, CONSTRAINT "fk_rails_12ff0084d7"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_knowledge_session_lists_on_knowledge_session_id" ON "knowledge_session_lists" ("knowledge_session_id") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_knowledge_session_lists_on_user_id" ON "knowledge_session_lists" ("user_id") /*application='NewsJaceProRr'*/;
CREATE TABLE "knowledge_session_participants" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "knowledge_session_id" integer NOT NULL, "participant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "hidden" boolean DEFAULT 0 NOT NULL, CONSTRAINT "fk_rails_7cd8619e8a"
FOREIGN KEY ("knowledge_session_id")
  REFERENCES "knowledge_sessions" ("id")
, CONSTRAINT "fk_rails_ec5ae3c93a"
FOREIGN KEY ("participant_id")
  REFERENCES "participants" ("id")
);
CREATE INDEX "index_knowledge_session_participants_on_knowledge_session_id" ON "knowledge_session_participants" ("knowledge_session_id") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_knowledge_session_participants_on_participant_id" ON "knowledge_session_participants" ("participant_id") /*application='NewsJaceProRr'*/;
CREATE TABLE "news_item_participants" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "news_item_id" integer NOT NULL, "participant_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b2ea04ce87"
FOREIGN KEY ("news_item_id")
  REFERENCES "news_items" ("id")
, CONSTRAINT "fk_rails_15b3d77df4"
FOREIGN KEY ("participant_id")
  REFERENCES "participants" ("id")
);
CREATE INDEX "index_news_item_participants_on_news_item_id" ON "news_item_participants" ("news_item_id") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_news_item_participants_on_participant_id" ON "news_item_participants" ("participant_id") /*application='NewsJaceProRr'*/;
CREATE TABLE "news_item_tags" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "news_item_id" integer NOT NULL, "tag_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_73da943f51"
FOREIGN KEY ("news_item_id")
  REFERENCES "news_items" ("id")
, CONSTRAINT "fk_rails_460735e3fd"
FOREIGN KEY ("tag_id")
  REFERENCES "tags" ("id")
);
CREATE INDEX "index_news_item_tags_on_news_item_id" ON "news_item_tags" ("news_item_id") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_news_item_tags_on_tag_id" ON "news_item_tags" ("tag_id") /*application='NewsJaceProRr'*/;
CREATE TABLE "news_items" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "item_type" varchar DEFAULT 'article', "active" boolean DEFAULT 1, "state" varchar DEFAULT 'new', "title" varchar, "body" text, "url" varchar, "image_url" varchar, "duration" varchar, "published_at" datetime(6), "event_start" datetime(6), "event_end" datetime(6), "event_location" varchar, "ad_url" varchar, "call_to_action" varchar, "news_feed_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_e9b21a7eb1"
FOREIGN KEY ("news_feed_id")
  REFERENCES "news_feeds" ("id")
);
CREATE INDEX "index_news_items_on_news_feed_id" ON "news_items" ("news_feed_id") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_news_items_on_title_and_published_at" ON "news_items" ("title", "published_at") /*application='NewsJaceProRr'*/;
CREATE UNIQUE INDEX "index_news_items_on_url" ON "news_items" ("url") /*application='NewsJaceProRr'*/;
CREATE TABLE "participants" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "alias" text, "company_name" varchar, "title" varchar, "bio" text, "image_url" varchar, "linkedin_url" varchar, "user_id" integer, "company_id" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "hidden" boolean, CONSTRAINT "fk_rails_2e03f17b01"
FOREIGN KEY ("company_id")
  REFERENCES "companies" ("id")
, CONSTRAINT "fk_rails_b9a3c50f15"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_participants_on_company_id" ON "participants" ("company_id") /*application='NewsJaceProRr'*/;
CREATE UNIQUE INDEX "index_participants_on_name" ON "participants" ("name") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_participants_on_user_id" ON "participants" ("user_id") /*application='NewsJaceProRr'*/;
CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE "mvp_awards" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "participant_id" integer NOT NULL, "year" integer NOT NULL, "award_type" varchar NOT NULL, "source_url" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_71bb1b8205"
FOREIGN KEY ("participant_id")
  REFERENCES "participants" ("id")
);
CREATE INDEX "index_mvp_awards_on_participant_id" ON "mvp_awards" ("participant_id");
CREATE INDEX "index_mvp_awards_on_year" ON "mvp_awards" ("year");
CREATE INDEX "index_mvp_awards_on_award_type" ON "mvp_awards" ("award_type");
CREATE UNIQUE INDEX "index_mvp_awards_unique" ON "mvp_awards" ("participant_id", "year", "award_type");
CREATE TABLE "snapp_cards" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "participant_id" integer NOT NULL, "edition" varchar NOT NULL, "card_name" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_8e188ce3bc"
FOREIGN KEY ("participant_id")
  REFERENCES "participants" ("id")
);
CREATE INDEX "index_snapp_cards_on_participant_id" ON "snapp_cards" ("participant_id");
CREATE INDEX "index_snapp_cards_on_edition" ON "snapp_cards" ("edition");
CREATE UNIQUE INDEX "index_snapp_cards_unique" ON "snapp_cards" ("participant_id", "edition", "card_name");
CREATE TABLE "startup_founders" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "participant_id" integer NOT NULL, "company_name" varchar NOT NULL, "source_url" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_591c8e12bd"
FOREIGN KEY ("participant_id")
  REFERENCES "participants" ("id")
);
CREATE INDEX "index_startup_founders_on_participant_id" ON "startup_founders" ("participant_id");
CREATE INDEX "index_startup_founders_on_company_name" ON "startup_founders" ("company_name");
CREATE UNIQUE INDEX "index_startup_founders_unique" ON "startup_founders" ("participant_id", "company_name");
CREATE INDEX "index_knowledge_sessions_on_canceled_at" ON "knowledge_sessions" ("canceled_at");
CREATE TABLE "search_documents" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "record_type" varchar NOT NULL, "record_id" integer NOT NULL, "title" varchar NOT NULL, "subtitle" varchar, "content" text, "url" text, "local_path" varchar NOT NULL, "destination_label" varchar NOT NULL, "occurred_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_search_documents_on_record_type_and_record_id" ON "search_documents" ("record_type", "record_id") /*application='NewsJaceProRr'*/;
CREATE INDEX "index_search_documents_on_record_type" ON "search_documents" ("record_type") /*application='NewsJaceProRr'*/;
CREATE VIRTUAL TABLE search_documents_fts USING fts5(
  title,
  subtitle,
  content,
  url,
  content='search_documents',
  content_rowid='id',
  tokenize='porter unicode61'
)
/* search_documents_fts(title,subtitle,content,url) */;
INSERT INTO "schema_migrations" (version) VALUES
('20260909004000'),
('20260909003000'),
('20260624152312'),
('20260509202121'),
('20260323192059'),
('20260323185402'),
('20260323185157'),
('20260228203939'),
('20260228201749'),
('20260227200003'),
('20260227200002'),
('20260227200001'),
('20260212053007'),
('20260212053006'),
('20260212052959'),
('20260212052958'),
('20260212052957'),
('20260212052951'),
('20260212052950'),
('20260212052949'),
('20260212052944'),
('20260212052942'),
('20260212052936'),
('20260212052935'),
('20260212052934');

