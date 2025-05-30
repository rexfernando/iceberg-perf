CREATE SCHEMA iceberg.tpch;

CREATE TABLE iceberg.tpch.synthetic_data (
         id BIGINT,
         name VARCHAR,
         value DOUBLE,
         created_at TIMESTAMP
     )
     WITH (
         format = 'PARQUET',
         location = 's3://warehouse/synthetic_data/'
     );

CREATE TABLE iceberg.tpch.numbers (
        n BIGINT
     )
     WITH (
         format = 'PARQUET',
         location = 's3://warehouse/numbers/'
     );

INSERT INTO iceberg.tpch.numbers
    SELECT n FROM UNNEST(sequence(1, 10000)) AS t(n);

INSERT INTO iceberg.tpch.synthetic_data
    SELECT
        row_number() OVER () AS id,
        concat('user_', cast(row_number() OVER () AS VARCHAR)) AS name,
        rand() * 1000 AS value,
        current_timestamp AS created_at
    FROM iceberg.tpch.numbers a
      CROSS JOIN iceberg.tpch.numbers b;


-- Simple Scan
SELECT count(*) FROM iceberg.tpch.synthetic_data;

-- Filtered Scan
SELECT count(*) FROM iceberg.tpch.synthetic_data WHERE value > 500;

-- Aggregation
SELECT name, avg(value) AS avg_value
FROM iceberg.tpch.synthetic_data
GROUP BY name
LIMIT 1000;

-- Complex filter and aggregation
SELECT date_trunc('day', created_at) AS day,
       count(*) AS record_count,
       avg(value) AS avg_value
FROM iceberg.tpch.synthetic_data
WHERE value BETWEEN 200 AND 800
GROUP BY date_trunc('day', created_at)
ORDER BY day;

-- Write Performance
INSERT INTO iceberg.tpch.synthetic_data
SELECT
    row_number() OVER () + 10000000 AS id,
    concat('user_', cast(row_number() OVER () + 10000000 AS VARCHAR)) AS name,
    rand() * 1000 AS value,
    current_timestamp AS created_at
FROM iceberg.tpch.numbers a
CROSS JOIN iceberg.tpch.numbers b
LIMIT 1000000;

