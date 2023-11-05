# PostgreSQL Aggregate Function README

This repository contains a PostgreSQL aggregate function named `max_to_min` that calculates the maximum and minimum values of a specified column in a given table and returns the result in a text format, like "max -> min."

## Requirements

To use this function, you need the following prerequisites:

- PostgreSQL version 12 or later

## Installation

- Download he extension files as zip
- Unzip the files in a location owned by postgres user. Do not change the file structure.
- Run make install. Th out put should be similar to (paths can vary depending on your postgresql install settings):

```bash
make install
/bin/mkdir -p '/usr/share/postgresql/12/extension'
/bin/mkdir -p '/usr/share/postgresql/12/extension'
/usr/bin/install -c -m 644 .//pg_minmax.control '/usr/share/postgresql/12/extension/'
/usr/bin/install -c -m 644 .//pg_minmax--0.0.1.sql  '/usr/share/postgresql/12/extension/'
```

- Create the extension on the desired PostgreSQL database:

```sql
postgres=# \c test
You are now connected to database "test" as user "postgres".

test=# create extension pg_minmax;
CREATE EXTENSION

test=# \dx
                  List of installed extensions
   Name    | Version |   Schema   |         Description
-----------+---------+------------+------------------------------
 pg_minmax | 0.0.1   | public     | Get min and max of a column
 plpgsql   | 1.0     | pg_catalog | PL/pgSQL procedural language
```

## Usage

Once the extension is installed, you can use the max_to_min function to retrieve the maximum and minimum values of a specified column in a table.

```sql
max_to_min(table_name text, column_name text) RETURNS text
```

### Examples

1. Finding the `max` and `min` on a column containing random integers.

```sql
test=# CREATE TABLE random_integers AS SELECT id AS random_column FROM generate_series(1, 10) AS id;
SELECT 10

test=# \dt
              List of relations
 Schema |      Name       | Type  |  Owner
--------+-----------------+-------+----------
 public | random_integers | table | postgres
(1 row)

test=# SELECT max_to_min('random_integers', 'random_column');
NOTICE:  Searching for table_name = random_integers, column_name = random_column, search_path = "$user",public
 max_to_min
------------
 10 -> 1
(1 row)
```

2. Finding the `max` and `min` on a column containing random timestamps.

```
test=# CREATE TABLE random_timestamps AS SELECT NOW() - random() * INTERVAL '365 days' AS random_column FROM generate_series(1, 10) AS id;
SELECT 10

test=# SELECT max_to_min('random_timestamps', 'random_column');
NOTICE:  Searching for table_name = random_timestamps, column_name = random_column, search_path = "$user",public
                          max_to_min
---------------------------------------------------------------
 2023-08-06 01:32:27.78987+00 -> 2023-01-02 00:08:39.806594+00
(1 row)
```

### Error Handling
The pg_minmax extension provides error handling for various scenarios, such as:

- Invalid column or table name
- Empty table
- Column with only NULL values

### Automated Testing
The repository also includes automated testing scripts to validate the correctness of the max_to_min function. Testing ensures that the function behaves as expected and helps catch any issues or regressions.

### Sample Data
To facilitate testing and usage, sample data tables (random_integers, random_floats, random_timestamps, and random_text) are provided within the repository. These tables contain random data for different data types.
