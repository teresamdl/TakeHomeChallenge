-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pg_minmax" to load this file. \quit

-- Drop the function if it exists
DROP FUNCTION IF EXISTS max_to_min(text, text);

-- Define a function that checks if the column exists in the specified table and returns max -> min
CREATE OR REPLACE FUNCTION max_to_min(table_name text, column_name text)
RETURNS text AS $$
DECLARE
    max_value text;
    min_value text;
    result_text text;
    table_column_exist boolean;
    table_has_records boolean;
    column_has_non_null_values boolean;
    search_path_value text;
BEGIN
    -- Fetch the current search_path
    EXECUTE 'SHOW SEARCH_PATH' INTO search_path_value;

    -- Debugging output
    RAISE NOTICE 'Searching for table_name = %, column_name = %, search_path = %', table_name, column_name, search_path_value;

    -- Check if the provided column name is valid for the specified table
    BEGIN
        EXECUTE 'SELECT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_name = $1 AND column_name = $2
        )' INTO table_column_exist
        USING table_name, column_name;
        
        IF NOT table_column_exist THEN
            -- Handle an invalid column name
            RAISE EXCEPTION 'Column % for table % not found.', column_name, table_name;
        END IF;
    END;

    -- Check if the table has records
    BEGIN
        EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I)', table_name) INTO table_has_records;
        
        IF NOT table_has_records THEN
            -- Handle the case when the table has no records
            RAISE EXCEPTION 'Table % has no records.', table_name;
        END IF;
    END;

    -- Check if the column has non-null values
    BEGIN
        EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I WHERE %I IS NOT NULL)', table_name, column_name) INTO column_has_non_null_values;
        
        IF NOT column_has_non_null_values THEN
            -- Handle the case when the column has only null values
            RAISE EXCEPTION 'Column % in table % has only null values.', column_name, table_name;
        END IF;
    END;

    BEGIN
    -- If all validations passed, proceed with the main logic
        EXECUTE format('SELECT MAX(%I), MIN(%I) FROM %I', column_name, column_name, table_name)
        INTO max_value, min_value;
        result_text := max_value || ' -> ' || min_value;
        RETURN result_text;

        EXCEPTION
            WHEN others THEN
                -- Handle any other unanticipated exceptions
                RAISE EXCEPTION 'An unexpected error occurred in the function. This may be due to invalid input data.';
    END;
END;
$$ LANGUAGE plpgsql;