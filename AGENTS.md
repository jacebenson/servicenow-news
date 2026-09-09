# News.jace.pro development guide

## What this app is

News.jace.pro is a Rails 8 ServiceNow data and news aggregation app.

It collects and presents:

- ServiceNow news from RSS feeds
- Knowledge conference sessions and recordings
- ServiceNow Store applications
- Partner companies and participants
- SEC filings and ServiceNow investments
- MVP, SNAPP card, and startup-founder data

The public UI is server-rendered Rails views with Tailwind CSS, Importmap, Turbo, and Stimulus. SQLite is the database. Solid Queue handles background jobs in production.

## Runtime

- Ruby: 3.4.5, pinned by `.ruby-version`
- Rails: 8.0.4
- Database: SQLite
- Web server: Puma
- CSS: `tailwindcss-rails` 4.x
- Jobs: Solid Queue
- Storage: local SQLite plus optional S3-compatible object storage
- Deployment: Docker Compose/Coolify

Use the repo's Ruby. If the shell has not loaded mise:

```bash
eval "$(mise activate bash)"
```

Check the environment:

```bash
ruby -v
bundle check
```

The expected Ruby version is 3.4.5. If Bundler reports every gem missing, the shell is probably using system Ruby or another mise version.

## Local development

Install dependencies:

```bash
mise exec ruby@3.4.5 -- bundle install
```

Start the app:

```bash
bin/dev
```

`Procfile.dev` starts:

- Rails on `0.0.0.0:3000`, so other machines can reach it
- Tailwind in persistent watch mode

Useful URLs:

- `http://localhost:3000/i`
- `http://pro-2:3000/i`
- `http://192.168.1.42:3000/i`

Development Host Authorization allows `pro-2`. Add any additional development hostname to `config/environments/development.rb` without a port, for example `config.hosts << "some-host"`.

After changing `Procfile.dev`, `config/puma.rb`, or an environment file, restart `bin/dev`. Remove a stale PID only when no Rails server is running:

```bash
rm -f tmp/pids/server.pid
```

## Database topology

Development uses:

```text
storage/development.sqlite3
```

Production defines separate SQLite databases:

```text
storage/production.sqlite3       # application data
storage/production_cache.sqlite3
storage/production_queue.sqlite3 # Solid Queue tables
storage/production_cable.sqlite3
```

The primary application schema is represented by `db/schema.rb`. Solid Queue has its own schema at `db/queue_schema.rb`.

Do not assume a production primary database contains Solid Queue tables. It does not. Development does not start Solid Queue inside Puma unless explicitly configured for it. Production does.

## Pulling a production database backup

The helper is a Rails runner, not a Rake task:

```bash
bin/rails runner scripts/download_prod_db.rb --list
bin/rails runner scripts/download_prod_db.rb YYYY-MM-DD
```

It expects these local environment variables, normally in the gitignored `.env` file:

```text
S3_BUCKET
S3_HOSTNAME
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Backups are written under `storage/backups/`.

Before using a downloaded SQLite file, verify it. Never copy an unverified file over the development database:

```bash
python3 - <<'PY'
import sqlite3
p = "storage/backups/YYYY-MM-DD.db"
con = sqlite3.connect(p)
print(con.execute("PRAGMA integrity_check").fetchone()[0])
PY
```

The result must be `ok`. A partial download can have a valid `SQLite format 3` header and still be unusable.

The downloader fetches the primary application database only. It does not fetch the production queue, cache, or cable databases. That is normally what local development needs.

## Environment and secrets

Local development uses `.env` or `.env.local`; both are gitignored. Production values come from Coolify application environment settings. Rails encrypted credentials use `config/credentials.yml.enc` plus the untracked `config/master.key`.

Never commit:

- `.env*`
- `config/master.key`
- S3 credentials
- Rails secret keys
- production database files

## Application structure

### Public controllers and routes

- `NewsItemsController`: `/i`, news search, RSS, item details
- `KnowledgeSessionsController`: `/sessions`, `/k20` through `/k26`, `/nulledge25`, filtering, saved lists, CSV export
- `ParticipantsController`: `/who/:name`
- `PartnersController`: `/p`
- `ApplicationsController`: `/a`
- `MvpAwardsController`: `/mvps`
- `AccountsController`: authenticated account settings
- `Api::CompaniesController` and `Api::ParticipantsController`: search endpoints

The catch-all slug route is last in `config/routes.rb`. Keep it last.

### Admin

Admin controllers live under `app/controllers/admin/` and use `Admin::BaseController`, which requires an authenticated admin user and uses the admin layout.

Important admin areas:

- Dashboard
- Background jobs
- News feeds and news items
- Companies and participants
- Knowledge sessions
- Store apps
- Investments
- Users

### Models

Core relationships:

- `NewsItem` belongs to an optional `NewsFeed`
- `NewsItem` has many `Participants` through `NewsItemParticipant`
- `NewsItem` has many `Tags` through `NewsItemTag`
- `KnowledgeSession` has many `Participants` through `KnowledgeSessionParticipant`
- `KnowledgeSession` has user saved lists through `KnowledgeSessionList`
- `Participant` can belong to a `Company`

JSON-like fields such as `participants`, `times`, `products`, and `services` are stored as text and parsed in model helpers.

## Background jobs

Jobs live in `app/jobs/`.

Main ingestion jobs:

- `FetchNewsItemsJob`: RSS feeds
- `FetchKnowledgeSessionsJob`: Knowledge conference data
- `FetchAppsJob`: ServiceNow Store apps
- `FetchPartnersJob`: partner data
- `FetchSecFilingsJob`: SEC filings
- `EnrichItemJob`: participant extraction and images
- `LinkParticipantsJob`: participant/company linking
- `ExtractVideoParticipantsJob`: video speakers
- `BackupJob`: S3 database backups

Use the admin background-jobs page for controlled manual runs. Do not run fetch or enrichment jobs against production casually; they make external requests and write data.

## Testing and checks

Run the test suite with the pinned Ruby:

```bash
mise exec ruby@3.4.5 -- bin/rails test
```

Useful focused checks:

```bash
mise exec ruby@3.4.5 -- bin/rails test test/models/news_item_test.rb
mise exec ruby@3.4.5 -- bin/rails test test/jobs/fetch_news_items_job_test.rb
mise exec ruby@3.4.5 -- bin/rails runner 'puts Rails.version'
ruby -c scripts/download_prod_db.rb
```

For request or UI work, verify the actual rendered response with the development server. A clean Rails boot is not enough.

## Change conventions

- Read the relevant controller, model, view, route, and migration before editing.
- Keep production behavior separate from development behavior.
- Add migrations for schema changes. Do not edit `db/schema.rb` by hand.
- Preserve SQLite database files. Never overwrite a database without a verified backup and an integrity check.
- Keep credentials out of git and tool output.
- Prefer small changes that can be exercised immediately.
- Do not add a new service or dependency when an existing Rails job, model, or service handles the same concern.

## Global search

The search-first entry point is `/` and the full search surface is `/s?q=...`. Search is local-only and uses a denormalized SQLite FTS5 index across public news, partners, applications, financial activity, events/sessions, and MVPs. Admin-only people and companies are not indexed as public result types.

Rebuild the index after a bulk import or data restoration:

```bash
mise exec ruby@3.4.5 -- bin/rails search:rebuild
```

The indexer streams records in batches. Do not replace it with an all-records-in-memory rebuild; the news corpus is large enough to trigger the OOM killer.

FTS5 requires `db/structure.sql`; `db/schema.rb` cannot represent the virtual table. The checked-in structure dump intentionally omits SQLite's internal FTS shadow-table definitions because SQLite recreates them when the virtual table is loaded.

## Known traps
- The repo may be opened under the wrong Ruby. Check `ruby -v` before diagnosing Bundler.
- `bin/dev` binds to all interfaces by design. This is useful on the trusted home network, not for exposing the development server to the public internet.
- Rails Host Authorization rejects bare hostnames until they are added to `config/environments/development.rb`.
- A downloaded SQLite file can be truncated after a timeout. Always run `PRAGMA integrity_check`.
- The production database backup helper downloads only the primary DB, not Solid Queue's separate DB.
- `SOLID_QUEUE_IN_PUMA=true` is production-oriented. Development must not launch the supervisor against a database without Solid Queue tables.
- The Tailwind watcher emits `watchman: command not found` on this machine but continues using its own watcher. Do not install the unrelated Watchman utility; Tailwind 4 has a known conflict with it.
- `config/deploy.yml` and `docker-compose.yaml` describe deployment separately from local `bin/dev`. Do not use production deployment settings as local development instructions.
