-- Migration: 0002_rebuild_schema
-- Drops the 0001 tables and replaces them with four new tables:
--   country   — lookup table of countries
--   company   — a company, tied to a country (FK)
--   employer  — a hiring entity / division inside a company (FK → company)
--   people    — a person, optionally linked to their current employer (FK → employer)
-- All tables carry created_at, updated_at, deleted_at for soft-delete support.
-- Seed data is inserted at the bottom.

-- ── Drop old tables in FK-safe order ────────────────────────────────────────
DROP TABLE IF EXISTS role           CASCADE;
DROP TABLE IF EXISTS activity_event CASCADE;
DROP TABLE IF EXISTS person         CASCADE;
DROP TABLE IF EXISTS employer       CASCADE;

-- ── New tables ───────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS country (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text        NOT NULL,
    code       text        NOT NULL,   -- ISO 3166-1 alpha-2, e.g. 'US', 'UA'
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);

CREATE TABLE IF NOT EXISTS company (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text        NOT NULL,
    industry   text,
    country_id uuid        NOT NULL REFERENCES country(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);

CREATE TABLE IF NOT EXISTS employer (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text        NOT NULL,
    company_id uuid        NOT NULL REFERENCES company(id) ON DELETE RESTRICT,
    location   text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);

CREATE TABLE IF NOT EXISTS people (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text        NOT NULL,
    email       text,
    employer_id uuid        REFERENCES employer(id) ON DELETE SET NULL,
    location    text,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),
    deleted_at  timestamptz
);

-- ── Seed data ────────────────────────────────────────────────────────────────

INSERT INTO country (id, name, code) VALUES
    ('11111111-0000-0000-0000-000000000001', 'United States', 'US'),
    ('11111111-0000-0000-0000-000000000002', 'Ukraine',        'UA'),
    ('11111111-0000-0000-0000-000000000003', 'Germany',        'DE')
ON CONFLICT (id) DO NOTHING;

INSERT INTO company (id, name, industry, country_id) VALUES
    ('22222222-0000-0000-0000-000000000001', 'Acme Corp',      'Technology',  '11111111-0000-0000-0000-000000000001'),
    ('22222222-0000-0000-0000-000000000002', 'Nova Systems',   'Consulting',  '11111111-0000-0000-0000-000000000002'),
    ('22222222-0000-0000-0000-000000000003', 'Berlin Labs',    'Research',    '11111111-0000-0000-0000-000000000003')
ON CONFLICT (id) DO NOTHING;

INSERT INTO employer (id, name, company_id, location) VALUES
    ('33333333-0000-0000-0000-000000000001', 'Acme Engineering',  '22222222-0000-0000-0000-000000000001', 'San Francisco, CA'),
    ('33333333-0000-0000-0000-000000000002', 'Nova Kyiv Office',  '22222222-0000-0000-0000-000000000002', 'Kyiv, Ukraine'),
    ('33333333-0000-0000-0000-000000000003', 'Berlin Labs HQ',    '22222222-0000-0000-0000-000000000003', 'Berlin, Germany')
ON CONFLICT (id) DO NOTHING;

INSERT INTO people (id, name, email, employer_id, location) VALUES
    ('44444444-0000-0000-0000-000000000001', 'Alice Johnson',  'alice@example.com',  '33333333-0000-0000-0000-000000000001', 'San Francisco, CA'),
    ('44444444-0000-0000-0000-000000000002', 'Oleksandr S.',   'alex@example.com',   '33333333-0000-0000-0000-000000000002', 'Kyiv, Ukraine'),
    ('44444444-0000-0000-0000-000000000003', 'Hans Müller',    'hans@example.com',   '33333333-0000-0000-0000-000000000003', 'Berlin, Germany'),
    ('44444444-0000-0000-0000-000000000004', 'Sara Conner',    'sara@example.com',   NULL,                                   'Remote')
ON CONFLICT (id) DO NOTHING;
