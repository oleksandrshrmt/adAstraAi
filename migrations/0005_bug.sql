-- Migration: 0003_reset_schema
-- Drops and recreates the four tables from 0002 with fresh seed data.
-- Reason: 0002 was applied before the seed was updated to use
-- gen_random_uuid(); this migration resets to the intended approach.

-- ── Drop in FK-safe order ─────────────────────────────────────────────────────
DROP TABLE IF EXISTS people   CASCADE;
DROP TABLE IF EXISTS employer CASCADE;
DROP TABLE IF EXISTS company  CASCADE;
DROP TABLE IF EXISTS country  CASCADE;

-- ── Recreate (schema identical to 0002) ──────────────────────────────────────
CREATE TABLE country (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text        NOT NULL,
    code       text        NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);

CREATE TABLE company (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text        NOT NULL,
    industry   text,
    country_id uuid        NOT NULL REFERENCES country(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);

CREATE TABLE employer (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text        NOT NULL,
    company_id uuid        NOT NULL REFERENCES company(id) ON DELETE RESTRICT,
    location   text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);

CREATE TABLE people (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text        NOT NULL,
    email       text,
    employer_id uuid        REFERENCES employer(id) ON DELETE SET NULL,
    location    text,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),
    deleted_at  timestamptz
);

-- ── Seed data via CTE chain (all IDs from gen_random_uuid()) ─────────────────
WITH
  ins_country AS (
    INSERT INTO country (name, code) VALUES
      ('United States', 'US'),
      ('Ukraine',       'UA'),
      ('Germany',       'DE')
    RETURNING id, code
  ),
  ins_company AS (
    INSERT INTO company (name, industry, country_id)
    SELECT v.name, v.industry, c.id
    FROM (VALUES
      ('Acme Corp',    'Technology', 'US'),
      ('Nova Systems', 'Consulting', 'UA'),
      ('Berlin Labs',  'Research',   'DE')
    ) AS v(name, industry, code)
    JOIN ins_country c ON c.code = v.code
    RETURNING id, name
  ),
  ins_employer AS (
    INSERT INTO employer (name, company_id, location)
    SELECT v.name, c.id, v.location
    FROM (VALUES
      ('Acme Engineering', 'Acme Corp',    'San Francisco, CA'),
      ('Nova Kyiv Office', 'Nova Systems', 'Kyiv, Ukraine'),
      ('Berlin Labs HQ',   'Berlin Labs',  'Berlin, Germany')
    ) AS v(name, company_name, location)
    JOIN ins_company c ON c.name = v.company_name
    RETURNING id, name
  )
INSERT INTO people (name, email, employer_id, location)
SELECT v.name, v.email, e.id, v.location
FROM (VALUES
  ('Alice Johnson', 'alice@example.com', 'Acme Engineering', 'San Francisco, CA'),
  ('Oleksandr S.',  'alex@example.com',  'Nova Kyiv Office', 'Kyiv, Ukraine'),
  ('Hans Müller',   'hans@example.com',  'Berlin Labs HQ',   'Berlin, Germany'),
  ('Sara Conner',   'sara@example.com',  NULL::text,         'Remote')
) AS v(name, email, employer_name, location)
LEFT JOIN ins_employer e ON e.name = v.employer_name;
