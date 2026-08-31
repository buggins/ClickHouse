-- Test for the `files` column in `system.projection_parts`.
-- https://github.com/ClickHouse/ClickHouse/issues/115133

DROP TABLE IF EXISTS t_projection_parts_files;

CREATE TABLE t_projection_parts_files
(
    key UInt64,
    value UInt64,
    PROJECTION proj
    (
        SELECT value, key
        ORDER BY value
    )
)
ENGINE = MergeTree
ORDER BY key;

INSERT INTO t_projection_parts_files SELECT number, number * 2 FROM numbers(100);

-- Each projection part has its own checksums with at least one file.
SELECT name, files > 0
FROM system.projection_parts
WHERE database = currentDatabase() AND table = 't_projection_parts_files' AND active;

DROP TABLE t_projection_parts_files;
