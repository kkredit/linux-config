SELECT
    n.nspname AS schema_name,
    t.typname AS enum_name,
    string_agg(e.enumlabel, ', ') AS enum_values
FROM
    pg_type t
JOIN
    pg_namespace n ON n.oid = t.typnamespace
JOIN
    pg_enum e ON t.oid = e.enumtypid
WHERE
    t.typtype = 'e'
GROUP BY
    n.nspname, t.typname;
