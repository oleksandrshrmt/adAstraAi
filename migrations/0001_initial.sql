-- Migration: 0001_initial
-- Creates the four core tables for Career OS:
--   person         — singleton profile row (only one row, ever)
--   employer       — companies worked at or being targeted
--   role           — positions held at an employer
--   activity_event — append-only log of career events

CREATE TABLE IF NOT EXISTS person (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text        NOT NULL,
    email       text,
    location    text,
    summary     text,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),
    deleted_at  timestamptz
);

CREATE TABLE IF NOT EXISTS employer (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text        NOT NULL,
    industry    text,
    size_range  text,
    location    text,
    summary     text,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),
    deleted_at  timestamptz
);

CREATE TABLE IF NOT EXISTS role (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    employer_id uuid        NOT NULL REFERENCES employer(id) ON DELETE RESTRICT,
    title       text        NOT NULL,
    level       text,
    started_at  date,
    ended_at    date,                 -- NULL means current (ongoing) role
    summary     text,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),
    deleted_at  timestamptz
);

-- activity_event is intentionally append-only: no updated_at, no deleted_at.
-- Career events are immutable facts. Corrections are new events (kind = 'correction'),
-- not silent edits. Omitting these columns enforces that at the schema level.
CREATE TABLE IF NOT EXISTS activity_event (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    occurred_at timestamptz NOT NULL DEFAULT now(),
    kind        text        NOT NULL,  -- e.g. 'shipped', 'learned', 'decided', 'failed', 'won'
    summary     text        NOT NULL,
    payload     jsonb,
    tags        text[],
    created_at  timestamptz NOT NULL DEFAULT now()
);
