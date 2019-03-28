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
CREATE TABLE model.example_four (
  id_example_four                 SERIAL,
  name                            TEXT NOT NULL,
  description                     TEXT,
  "array"                         INTEGER ARRAY,
  created_at                      TIMESTAMP DEFAULT NOW(),
  updated_at                      TIMESTAMP DEFAULT NOW(),
  CONSTRAINT example_four_pkey    PRIMARY KEY (id_example_four)
);

CREATE TRIGGER trigger_model_example_four_updated_at BEFORE UPDATE
  ON model.example_four FOR EACH ROW EXECUTE PROCEDURE model.function_updated_at();
