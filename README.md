# DataHound

A Rails application for importing and analyzing supplier quotes. Upload CSV data, normalize rates across tax-inclusive and tax-exclusive quotes, and compare suppliers at a glance.

## Stack

- Ruby 4.0.2 / Rails 8.1.3
- PostgreSQL
- Solid Queue (background jobs), Solid Cache, Solid Cable (ActionCable)
- Hotwire (Turbo Streams + Turbo Frames)
- Tailwind CSS v4 with semantic design tokens
- Pagy (pagination)
- Minitest + Capybara

## Getting Started

### With Docker

```bash
docker compose up
```

This starts PostgreSQL, the web server (with automatic `db:prepare`), and the background worker. The app is available at [http://localhost:3000](http://localhost:3000).

### Local Development

```bash
bin/setup
bin/dev
```

`bin/dev` starts the Rails server, Tailwind watcher, and Solid Queue worker via Foreman.

## Running Tests

```bash
bin/ci                 # Full CI pipeline: setup, lint, security, tests (unit + system)
bin/rails test         # Unit and integration tests (66 tests)
bin/rails test:system  # System tests with headless Chrome (11 tests)
```

77 tests total covering models, services, controllers, jobs, and end-to-end user flows.

## Features

### CSV Import

Upload a CSV file via the web interface. The file is persisted with Active Storage, then processed in a background job:

- **Streaming parser** — `CSV.foreach` processes line-by-line. Memory stays flat for 500MB+ files.
- **Batch upsert** — Rows are batched (1000 at a time) and upserted with a composite unique key. Re-importing the same file is idempotent.
- **Fault tolerant** — Malformed rows are collected and reported without halting the import. File-level errors (missing file, bad headers) mark the import as failed.
- **Real-time progress** — Turbo Streams broadcast status updates (row count, completion summary) over ActionCable. No polling.

### Quotes Index

Paginated table (25 per page) displaying all CSV columns plus the computed normalized rate. Features:

- **Filtering** — by state, supplier, and tax included (Y/N)
- **Sorting** — by rate, normalized rate, customer name, or supplier name
- **Turbo Frames** — filter/sort/pagination update the table without full page reload
- **URL state** — filter and sort params are preserved in the URL for bookmarking

### Customer Summary

Aggregated view grouped by customer showing:

- Quote count, best (lowest) normalized rate, average rate, and rate spread
- Best quote highlighted with supplier name
- SQL aggregations (`COUNT`, `MIN`, `AVG`, `MAX - MIN`) — two queries total, no N+1

## Data Model

See [docs/erd.md](docs/erd.md) for the full entity relationship diagram.

Five tables (four domain + one operational):

- **Region** — US state abbreviation, country code, and tax rate
- **Customer** — belongs to a region
- **Supplier** — provider
- **Quote** — a supplier's quoted rate for a customer, with a `normalized_rate` for apples-to-apples comparison
- **Import** — tracks upload lifecycle (pending → processing → completed/failed) with Active Storage file attachment

### Rate Normalization

Quotes in the source data are a mix of tax-inclusive and tax-exclusive rates. All quotes are normalized to a pre-tax rate on import:

- Tax-included: `rate / (1 + region.tax_rate / 100.0)`
- Tax-excluded: stored as-is

This enables DB-level sorting and filtering on `normalized_rate` without runtime computation.

## Architecture

```
┌─────────────────────────────────────────┐
│            BOUNDARY LAYER               │
│  Controllers, ImportQuotesJob           │
│  (receive input, delegate to services)  │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           SERVICE LAYER                 │
│  QuotesImporter, QuotesCsvParser        │
│  (business logic, isolated, testable)   │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│            MODEL LAYER                  │
│  Quote, Customer, Supplier, Region      │
│  (database access, validations, scopes) │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│            DATABASE LAYER               │
│  PostgreSQL — constraints, indexes, FKs │
└─────────────────────────────────────────┘
```

- **Business logic lives in services.** `QuotesImporter` owns the import lifecycle. `QuotesCsvParser` handles file validation and row parsing with no ActiveRecord dependency.
- **Jobs are thin boundary classes.** `ImportQuotesJob` is 9 lines — finds the import, delegates to the service.
- **Models are for database access.** Validations, associations, scopes. No business logic.
- **Database constraints enforce correctness.** NOT NULL, foreign keys, composite unique indexes. Validations exist for user experience.

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| `Region` instead of `State` | Avoids ambiguity with software "state"; extensible to non-US markets |
| `tax_rate` on Region, not Customer | 3NF — eliminates transitive dependency (customer → region → tax_rate) |
| `normalized_rate` stored on import | Enables DB-level sorting/filtering; avoids runtime computation on large datasets |
| Composite unique index on Quote | Enforces one quote per customer-supplier pair; enables idempotent upserts |
| Active Storage for uploads | File persists before job runs — no temp file race condition |
| Streaming CSV + batch upsert | Memory-efficient for 500MB+ files; 1000-row batches balance throughput and memory |
| Solid Queue / Solid Cable | Rails 8 defaults; no Redis dependency; database-backed |
| Turbo Streams for progress | Real-time feedback without polling; pure ActionCable over Solid Cable |
| Pagy for pagination | Lightweight, no dependencies, efficient SQL (LIMIT/OFFSET) |
| Semantic design tokens | `--bg-primary` instead of `bg-blue-700`; theme-aware, consistent |

## Dev Docs

In development, visit [/docs](http://localhost:3000/docs) for an interactive architecture walkthrough covering the layer diagram, data model, import pipeline, and design system. These routes are not available in production.
