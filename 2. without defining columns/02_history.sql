CREATE SCHEMA history;

CREATE TYPE history.operation AS ENUM ('I', 'U', 'D');

CREATE TABLE history.example_one (
  _id_history SERIAL    PRIMARY KEY,
  _user                 TEXT NOT NULL,
  _operation operation  NOT NULL,
  _operation_at         TIMESTAMP DEFAULT NOW(),
  LIKE model.example_one
);

CREATE OR REPLACE FUNCTION function_example_one_history() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO history.example_one VALUES(user, 'I', now(), OLD.*);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO history.example_one VALUES(user, 'U', now(), NEW.*);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO history.example_one VALUES(user, 'D', now(), NEW.*);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_example_one_history
AFTER INSERT OR UPDATE OR DELETE ON model.example_one
    FOR EACH ROW EXECUTE PROCEDURE function_example_one_history();