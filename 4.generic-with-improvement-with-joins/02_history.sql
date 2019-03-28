CREATE SCHEMA history;

CREATE TYPE history.operation AS ENUM ('I', 'U', 'D');

CREATE TABLE history.example_four (
  _id_history SERIAL    PRIMARY KEY,
  _user                 TEXT NOT NULL,
  _operation operation  NOT NULL,
  _operation_at         TIMESTAMP DEFAULT NOW(),
  LIKE model.example_four
);

CREATE OR REPLACE FUNCTION create_insert_history_statement(_history_schema_name text, _history_table_name text, _model_schema_name text, _model_table_name text, _row anyelement, _operation history.operation) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	_rec RECORD;
	_value text;
	_columns text[];
	_values text[];
BEGIN
FOR _rec IN
    SELECT pg_attribute.attname AS column_name
    FROM pg_class
    JOIN pg_attribute ON pg_attribute.attrelid = pg_class.oid
    JOIN pg_catalog.pg_namespace ON pg_namespace.oid = pg_class.relnamespace
    WHERE  pg_namespace.nspname = _model_schema_name AND pg_class.relname = _model_table_name
    AND    pg_attribute.attnum > 0
    AND    NOT pg_attribute.attisdropped
    ORDER  BY pg_attribute.attnum
LOOP
	IF substring(_rec.column_name, 1, 1) <> '_' THEN
		EXECUTE 'SELECT ($1).' || _rec.column_name INTO STRICT _value USING _row;
	    _columns := _columns || quote_ident(_rec.column_name::text);
	    _values := _values || format('%L', _value);
	END IF;
END LOOP;
RETURN format('INSERT INTO %s.%s (_user, _operation, _operation_at, %s) VALUES (%L, %L, %L, %s)', _history_schema_name, _history_table_name, array_to_string(_columns, ','), USER, _operation, NOW(), array_to_string(_values, ','));
END;
$$;

CREATE OR REPLACE FUNCTION function_insert_history() RETURNS TRIGGER AS $$
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
    	--RAISE NOTICE 'Testing [%]', create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, NEW, 'I');
        EXECUTE(create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, NEW, 'I'));
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
    	--RAISE EXCEPTION 'Testing [%]', create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, NEW, 'U');
        EXECUTE(create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, NEW, 'U'));
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
    	--RAISE EXCEPTION 'Testing [%]', create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, OLD, 'D');
        EXECUTE(create_insert_history_statement(_history_schema_name, _history_table_name, _model_schema_name, _model_table_name, OLD, 'D'));
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

CREATE TRIGGER trigger_example_four_history
AFTER INSERT OR UPDATE OR DELETE ON model.example_four
    FOR EACH ROW EXECUTE PROCEDURE function_insert_history();