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
CREATE TABLE model.example_six (
  id_example_six                 SERIAL,
  name                            TEXT NOT NULL,
  description                     TEXT,
  "array"                         INTEGER ARRAY,
  created_at                      TIMESTAMP DEFAULT NOW(),
  updated_at                      TIMESTAMP DEFAULT NOW(),
  CONSTRAINT example_six_pkey    PRIMARY KEY (id_example_six)
);

CREATE TRIGGER trigger_model_example_six_updated_at BEFORE UPDATE
  ON model.example_six FOR EACH ROW EXECUTE PROCEDURE model.function_updated_at();
