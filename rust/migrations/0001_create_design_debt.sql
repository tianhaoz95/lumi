-- Migration: create design_debt table (dev-only)
CREATE TABLE IF NOT EXISTS design_debt (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  screen TEXT,
  description TEXT,
  status TEXT DEFAULT 'open'
);
