CREATE SCHEMA model;

-- GLOBAL
CREATE OR REPLACE FUNCTION model.function_updated_at()
  RETURNS TRIGGER AS $$
  BEGIN
   NEW.updated_at = now();
   RETURN NEW;
  END;
  $$ LANGUAGE 'plpgsql';


-- PROCESS
CREATE TABLE model.example_zero (
  id_example_zero                 SERIAL,
  name                            TEXT NOT NULL,
  description                     TEXT,
  "array"                         INTEGER ARRAY,
  created_at                      TIMESTAMP DEFAULT NOW(),
  updated_at                      TIMESTAMP DEFAULT NOW(),
  CONSTRAINT example_zero_pkey    PRIMARY KEY (id_example_zero)
);
