BEGIN;

INSERT INTO iris_core.parcel (
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    completeness_status,
    geom,
    created_at
)
SELECT
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    completeness_status,
    ST_Multi(
        ST_Transform(geom, 4326)
    )::geometry(MultiPolygon, 4326),
    created_at
FROM iris_staging.feature
WHERE feature_type = 'parcel'
  AND GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON')
  AND ST_NDims(geom) = 2
  AND ST_IsValid(geom);

INSERT INTO iris_core.substation (
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    name,
    completeness_status,
    geom,
    created_at
)
SELECT
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    name,
    completeness_status,
    ST_Transform(geom, 4326)::geometry(Point, 4326),
    created_at
FROM iris_staging.feature
WHERE feature_type = 'substation'
  AND GeometryType(geom) = 'POINT'
  AND ST_NDims(geom) = 2
  AND name IS NOT NULL;

INSERT INTO iris_core.peatland (
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    classification,
    completeness_status,
    geom,
    created_at
)
SELECT
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    classification,
    completeness_status,
    ST_Multi(
        ST_Transform(geom, 4326)
    )::geometry(MultiPolygon, 4326),
    created_at
FROM iris_staging.feature
WHERE feature_type = 'peatland'
  AND GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON')
  AND ST_NDims(geom) = 2
  AND ST_IsValid(geom);

INSERT INTO iris_core.screening_layer (
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    name,
    category,
    completeness_status,
    geom,
    created_at
)
SELECT
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    name,
    category,
    completeness_status,
    ST_Multi(
        ST_Transform(geom, 4326)
    )::geometry(MultiPolygon, 4326),
    created_at
FROM iris_staging.feature
WHERE feature_type = 'screening_layer'
  AND GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON')
  AND ST_NDims(geom) = 2
  AND ST_IsValid(geom)
  AND name IS NOT NULL
  AND category IS NOT NULL;

COMMIT;
