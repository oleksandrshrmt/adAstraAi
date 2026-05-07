-- drop.sql — manual reset utility
-- Run this by hand to wipe the schema and start fresh, e.g.:
--   psql "$DATABASE_URL" -f migrations/drop.sql
--
-- This file is NOT picked up by the CI migration workflow (which only
-- runs files matching 0000_*.sql) and must never be committed as a
-- numbered migration.

DROP TABLE IF EXISTS people          CASCADE;
DROP TABLE IF EXISTS employer        CASCADE;
DROP TABLE IF EXISTS company         CASCADE;
DROP TABLE IF EXISTS country         CASCADE;
-- legacy tables from 0001
DROP TABLE IF EXISTS role            CASCADE;
DROP TABLE IF EXISTS activity_event  CASCADE;
DROP TABLE IF EXISTS person          CASCADE;
DROP TABLE IF EXISTS schema_migrations CASCADE;
