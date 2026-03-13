# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## App Purpose

**Personal Finance SaaS** — a multi-user application for comprehensive personal financial management.

### Who uses it
- Individual users, each with fully isolated data
- Global / country-agnostic (no country-specific bank integrations initially)
- Free tier only — no subscription/plan logic needed

### Authentication
- Email/password via Rails 8 authentication generator
- Google Social login via Omniauth + `OauthIdentity` model

### Core Modules
1. **Transactions** — income, expenses, transfers; manual entry, CSV/OFX import, recurring templates
2. **Categories** — hierarchical (parent → subcategory); predefined system + user custom; scoped to income/expense/both
3. **Assets** — physical assets (houses, cars); value history, financing/loan tracking, cost-of-ownership
4. **Investments** — holdings, buy/sell/dividend/split; portfolio allocation by asset class & geography; P&L + XIRR; price auto-fetch
5. **Budget** — monthly category spending limits with progress tracking
6. **Dashboard** — monthly overview, budget bars, net worth over time, cash flow forecast

### Multi-Currency
Transactions, accounts, and investments can be in any currency. User sets a **base currency** for consolidated reporting.

---

## Domain Model

```
User
  has_many :accounts
  has_many :categories          # includes predefined/system (category.user_id nil = system)
  has_many :transactions        # through accounts
  has_many :recurring_templates
  has_many :assets
  has_many :investments
  has_many :budgets

Account
  belongs_to :user
  fields: name, account_type (checking|savings|credit_card|cash|investment),
          currency, balance, institution_name

Category
  belongs_to :user              # nil = predefined/system category
  belongs_to :parent, class_name: 'Category'   # self-referential hierarchy
  fields: name, icon, color, transaction_type (income|expense|both), predefined

Transaction
  belongs_to :account
  belongs_to :category
  belongs_to :asset             # optional — for cost-of-ownership tagging
  belongs_to :recurring_template  # optional — generated from template
  fields: date, amount, currency, description, notes,
          transaction_type (income|expense|transfer), status (pending|paid|scheduled),
          exchange_rate

RecurringTemplate
  belongs_to :account
  belongs_to :category
  fields: description, amount, currency, frequency, next_due_date, end_date,
          transaction_type, day_of_month

Asset
  belongs_to :user
  has_many :asset_valuations
  has_one :asset_loan
  has_many :transactions        # expenses + income linked to this asset
  fields: name, asset_type (house|car|other), purchase_date, purchase_price,
          currency, description

AssetValuation
  belongs_to :asset
  fields: date, value, currency, notes

AssetLoan
  belongs_to :asset
  fields: lender, total_amount, interest_rate, number_of_installments,
          installment_amount, start_date, end_date, currency

Investment
  belongs_to :user
  has_many :investment_transactions
  has_many :investment_prices
  fields: name, ticker_symbol,
          asset_class (stocks|bonds|crypto|real_estate|fixed_income|other),
          country, currency, exchange

InvestmentTransaction
  belongs_to :investment
  fields: transaction_type (buy|sell|dividend|split|fee), date, quantity,
          price, currency, fees, exchange_rate

InvestmentPrice
  belongs_to :investment
  fields: date, price, currency, fetched_at   # fetched_at tracks auto-fetch runs

Budget
  belongs_to :user
  belongs_to :category
  fields: month (date — first day of month), amount_limit, currency
```

---

## Development Phases

### Phase 1 — Foundation ✅ (current)
1. Rails 8 authentication generator (`rails generate authentication`)
2. Omniauth Google + `OauthIdentity` model
3. `Account` model + CRUD
4. `Category` model (hierarchical, predefined seed data)
5. `Transaction` model + CRUD (income/expense)
6. Basic dashboard (monthly overview card)

### Phase 2 — Budget & Recurring
7. `RecurringTemplate` model + CRUD
8. Background job: generate transactions from templates (Solid Queue)
9. CSV/OFX import pipeline (upload → parse → map fields → confirm → save)
10. `Budget` model + CRUD + progress view

### Phase 3 — Assets
11. `Asset` model + CRUD
12. `AssetValuation` (value history chart)
13. `AssetLoan` (financing installment tracker)
14. Link transactions to assets + cost-of-ownership view

### Phase 4 — Investments
15. `Investment` + `InvestmentTransaction` CRUD
16. Portfolio allocation view (by class + country)
17. Performance tracking (P&L, XIRR)
18. Price auto-fetch job (Yahoo Finance / crypto APIs)

### Phase 5 — Advanced Reporting
19. Net worth over time chart
20. Cash flow forecast (calendar/timeline)
21. Multi-currency consolidation (exchange rates, base currency setting)

---

## Stack

- **Ruby 3.4.4**, **Rails 8.1**
- **SQLite3** (all environments, including production via Docker volume)
- **Propshaft** (asset pipeline), **Importmap** (JS, no bundler)
- **Hotwire** (Turbo + Stimulus) for frontend interactivity
- **Solid Cache / Solid Queue / Solid Cable** — DB-backed adapters (no Redis required)
- **Kamal** for deployment

## Commands

```bash
bin/setup           # Install deps, create and migrate DB, start services
bin/dev             # Start dev server

bin/rails test                  # Run all unit/integration tests
bin/rails test test/models/foo_test.rb                  # Run a single test file
bin/rails test test/models/foo_test.rb:42               # Run a single test by line
bin/rails test:system           # Run system (Capybara/Selenium) tests

bin/rubocop                     # Lint Ruby (rubocop-rails-omakase style)
bin/rubocop -a                  # Auto-correct safe offenses

bin/brakeman --quiet --no-pager # Security static analysis
bin/bundler-audit               # Audit gems for known vulnerabilities
bin/importmap audit             # Audit JS importmap packages

bin/ci                          # Full CI suite (setup → lint → security → tests)
```

## Architecture

### Database

Production uses four separate SQLite databases (defined in `config/database.yml`):
- `production.sqlite3` — primary app data
- `production_cache.sqlite3` — Solid Cache
- `production_queue.sqlite3` — Solid Queue
- `production_cable.sqlite3` — Solid Cable

In development/test, only the primary database is used. Schema files for the secondary DBs live at `db/cable_schema.rb`, `db/cache_schema.rb`, `db/queue_schema.rb`.

### Background Jobs

Solid Queue (`config/queue.yml`) replaces traditional job backends. Recurring jobs are configured in `config/recurring.yml`.

### CI Pipeline

`bin/ci` (defined in `config/ci.rb`) orchestrates: setup → rubocop → bundler-audit → importmap audit → brakeman → rails test → system test → seed replant.

### Deployment

Kamal config lives in `config/deploy.yml`. Secrets are referenced from `.kamal/secrets`. The app runs as a Docker container via `Dockerfile`, fronted by Thruster (HTTP caching/compression proxy for Puma).

## Linting Style

Uses `rubocop-rails-omakase` — the Rails team's opinionated defaults. Overrides go in `.rubocop.yml`.
