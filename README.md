# DataHound

A Rails application for importing and analyzing energy supplier quotes. Upload CSV data, normalize rates across tax-inclusive and tax-exclusive quotes, and compare suppliers at a glance.

## Stack

- Ruby 4.0.2 / Rails 8.1.3
- PostgreSQL
- Solid Queue (background jobs), Solid Cache, Solid Cable
- Hotwire (Turbo + Stimulus)
- Tailwind CSS v4
- Minitest

## Getting Started

### With Docker

```bash
docker compose up
```

This starts the web server, PostgreSQL database, and background worker.

### Local Development

```bash
bin/setup
bin/dev
```

`bin/dev` starts the Rails server, Tailwind watcher, and Solid Queue worker via Foreman.

## Running Tests

```bash
bin/ci              # Full CI pipeline: setup, lint, security, tests
bin/rails test      # Unit and integration tests
bin/rails test:system  # System tests (Capybara + headless Chrome)
```

## Data Model

See [docs/erd.md](docs/erd.md) for the full entity relationship diagram.

Four normalized tables (3NF):

- **Region** — US state abbreviation, country code, and tax rate
- **Customer** — belongs to a region
- **Supplier** — energy provider
- **Quote** — a supplier's quoted rate for a customer, with a `normalized_rate` for comparison

### Rate Normalization

Quotes in the source data are a mix of tax-inclusive and tax-exclusive rates. To enable fair comparison, all quotes are normalized to a pre-tax (tax-exclusive) rate on import:

- Tax-included quotes: `rate / (1 + region.tax_rate / 100.0)`
- Tax-excluded quotes: stored as-is

## Architecture Decisions

| Decision                                                     | Rationale                                                                        |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------- |
| `Region` instead of `State`                                  | Avoids ambiguity with software "state"; extensible to non-US markets             |
| `tax_rate` on Region, not Customer                           | 3NF — eliminates transitive dependency (customer -> region -> tax_rate)          |
| `normalized_rate` stored on import                           | Enables DB-level sorting/filtering; avoids runtime computation on large datasets |
| Composite unique index on Quote `[customer_id, supplier_id]` | Enforces data integrity; enables idempotent re-imports via upsert                |
| Streaming CSV parse + background job                         | Memory-efficient for 500MB+ files; non-blocking UI                               |
| Solid Queue over Sidekiq                                     | Rails 8 default; no Redis dependency                                             |
