CREATE SCHEMA history;

CREATE TYPE history.operation AS ENUM ('I', 'U', 'D');

CREATE TABLE history.example_one (
  _id_history SERIAL    PRIMARY KEY,
  _user                 TEXT NOT NULL,
  _operation operation  NOT NULL,
  _operation_at         TIMESTAMP DEFAULT NOW(),
  LIKE model.example_one
);

CREATE OR REPLACE FUNCTION create_insert_history_statement(_schemaname text, _tablename text, _row anyelement, _operation history.operation) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
  _value text;
  _columns text[];
  _values text[];
BEGIN
FOR rec IN
    SELECT column_name
    FROM information_schema.columns
    WHERE
        table_schema = quote_ident(_schemaname)
    AND table_name = quote_ident(_tablename)
    ORDER BY ordinal_position
LOOP
	IF substring(rec.column_name, 1, 1) <> '_' THEN
		EXECUTE 'SELECT ($1).' || rec.column_name INTO STRICT _value USING _row;
	    _columns := _columns || quote_ident(rec.column_name::text);
	    _values := _values || format('%L', _value);
	END IF;
END LOOP;
RETURN format('INSERT INTO history.%s (_user, _operation, _operation_at, %s) VALUES (%L, %L, %L, %s)', _tablename, array_to_string(_columns, ','), user, _operation, now(), array_to_string(_values, ','));
END;
$$;

CREATE OR REPLACE FUNCTION function_insert_history() RETURNS TRIGGER AS $$
begin
    IF (TG_OP = 'INSERT') then
    	--RAISE EXCEPTION 'Testing [%!]', create_insert_statement(TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD);
        EXECUTE(create_insert_history_statement(TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW, 'I'));
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') then
      -- catch errors
    	--RAISE EXCEPTION 'Testing [%!]', create_insert_statement(TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW);
        EXECUTE(create_insert_history_statement(TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW, 'U'));
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') then
    	--RAISE EXCEPTION 'Testing [%!]', create_insert_statement(TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW);
		EXECUTE(create_insert_history_statement(TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD, 'D'));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_example_one_history
AFTER INSERT OR UPDATE OR DELETE ON model.example_one
    FOR EACH ROW EXECUTE PROCEDURE function_insert_history();