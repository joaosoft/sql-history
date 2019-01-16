CREATE SCHEMA history;

CREATE TYPE history.operation AS ENUM ('I', 'U', 'D');

CREATE TABLE history.example_two (
  _id_history SERIAL    PRIMARY KEY,
  _user                 TEXT NOT NULL,
  _operation operation  NOT NULL,
  _operation_at         TIMESTAMP DEFAULT NOW(),
  LIKE model.example_two
);

CREATE OR REPLACE FUNCTION function_example_two_history() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO history.example_two VALUES(DEFAULT, USER, 'I', NOW(), NEW.*);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO history.example_two VALUES(DEFAULT, USER, 'U', NOW(), NEW.*);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO history.example_two VALUES(DEFAULT, USER, 'D', NOW(), OLD.*);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_example_two_history
AFTER INSERT OR UPDATE OR DELETE ON model.example_two
    FOR EACH ROW EXECUTE PROCEDURE function_example_two_history();