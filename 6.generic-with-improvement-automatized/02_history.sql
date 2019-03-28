CREATE SCHEMA history;

CREATE TYPE history.operation AS ENUM ('I', 'U', 'D');

CREATE OR REPLACE FUNCTION history.create_insert_history_statement(_history_schema_name text, _history_table_name text, _model_schema_name text, _model_table_name text, _row anyelement, _operation history.operation) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	_rec RECORD;
	_value text;
	_columns text[];
	_values text[];
BEGIN
FOR _rec IN
    SELECT attname AS column_name
    FROM   pg_attribute
    WHERE  attrelid = (_model_schema_name || '.' || _model_table_name)::regclass
    AND    attnum > 0
    AND    NOT attisdropped
    ORDER  BY attnum
LOOP
	IF substring(_rec.column_name, 1, 1) <> '_' THEN
		EXECUTE 'SELECT ($1).' || _rec.column_name INTO STRICT _value USING _row;
	    _columns := _columns || quote_ident(_rec.column_name::text);
	    _values := _values || format('%L', _value);
	END IF;
END LOOP;
RETURN format('INSERT INTO "%s"."%s" (_user, _operation, _operation_at, %s) VALUES (%L, %L, %L, %s)', _history_schema_name, _history_table_name, array_to_string(_columns, ','), USER, _operation, NOW(), array_to_string(_values, ','));
END;
$$;

CREATE OR REPLACE FUNCTION history.function_insert_history() RETURNS TRIGGER AS $$
DECLARE
  _err_context text;
  _history_schema_name text;
  _history_table_name text;
  _model_schema_name text;
  _model_table_name text;
BEGIN
    _history_schema_name := 'history';
   	_history_table_name := TG_TABLE_NAME;
  	_model_schema_name := TG_TABLE_SCHEMA;
 	  _model_table_name := TG_TABLE_NAME;
	IF (TG_OP = 'INSERT') THEN
    	--RAISE EXCEPTION 'Testing [%!]', history.create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, NEW, 'I');
        EXECUTE(history.create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, NEW, 'I'));
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
      -- catch errors
    	--RAISE EXCEPTION 'Testing [%!]', history.create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, NEW, 'U');
        EXECUTE(history.create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, NEW, 'U'));
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
    	--RAISE EXCEPTION 'Testing [%!]', history.create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, OLD, 'D');
        EXECUTE(history.create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, OLD, 'D'));
        RETURN OLD;
    END IF;
	EXCEPTION
	WHEN OTHERS THEN
	  GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
		RAISE EXCEPTION 'Error context: %; Error name: %; Error state: %', _err_context, SQLERRM, SQLSTATE
		  USING HINT = format('Check history table [%s.%s] of table [%s.%s]', _history_schema_name, _history_table_name, _model_schema_name, _model_table_name),
		  SCHEMA = _history_schema_name,
		  TABLE = _history_table_name;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION history.create_history_table(_history_schema_name text, _history_table_name text, _model_schema_name text, _model_table_name text)
  RETURNS VOID AS
$func$
DECLARE
  _err_context text;
BEGIN
EXECUTE format('
  CREATE TABLE IF NOT EXISTS %I.%I (
    _id_history           SERIAL PRIMARY KEY,
    _user                 TEXT NOT NULL,
    _operation            history.operation NOT NULL,
    _operation_at         TIMESTAMP DEFAULT NOW(),
    LIKE %I.%I
  );

  CREATE TRIGGER trigger_%I_%I_history
  AFTER INSERT OR UPDATE OR DELETE ON %I.%I
    FOR EACH ROW EXECUTE PROCEDURE history.function_insert_history();',
      _history_schema_name, _history_table_name,
 	  _model_schema_name, _model_table_name,
 	  _model_schema_name, _model_table_name,
 	  _model_schema_name, _model_table_name);
EXCEPTION
    WHEN OTHERS THEN
      GET STACKED DIAGNOSTICS _err_context = PG_EXCEPTION_CONTEXT;
        RAISE EXCEPTION 'Error context: %; Error name: %; Error state: %', _err_context, SQLERRM, SQLSTATE
          USING HINT = format('Check table [%s.%s]', _model_schema_name, _model_table_name),
          SCHEMA = _model_schema_name,
          TABLE = _model_table_name;
END

$func$ LANGUAGE plpgsql;


SELECT history.create_history_table('history', 'example_six', 'model', 'example_six');