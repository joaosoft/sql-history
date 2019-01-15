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
        INSERT INTO history.example_one(_user, _operation, _operation_at, id_example_one, name, description, "array", created_at, updated_at) VALUES(USER, 'I', NOW(), NEW.id_example_one, OLD.name, OLD.description, OLD.array, OLD.created_at, OLD.updated_at);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO history.example_one(_user, _operation, _operation_at, id_example_one, name, description, "array", created_at, updated_at) VALUES(USER, 'U', NOW(), NEW.id_example_one, NEW.name, NEW.description, OLD.array, NEW.created_at, NEW.updated_at);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO history.example_one(_user, _operation, _operation_at, id_example_one, name, description, "array", created_at, updated_at) VALUES(USER, 'D', NOW(), OLD.id_example_one, NEW.name, NEW.description, OLD.array, NEW.created_at, NEW.updated_at);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_example_one_history
AFTER INSERT OR UPDATE OR DELETE ON model.example_one
    FOR EACH ROW EXECUTE PROCEDURE function_example_one_history();