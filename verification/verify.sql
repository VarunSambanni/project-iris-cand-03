SELECT
    current_setting('server_version') AS postgresql_version,
    PostGIS_Version() AS postgis_version;

SELECT entity, row_count
FROM (
    SELECT 'parcel' AS entity, count(*) AS row_count
    FROM iris_core.parcel

    UNION ALL

    SELECT 'substation', count(*)
    FROM iris_core.substation

    UNION ALL

    SELECT 'peatland', count(*)
    FROM iris_core.peatland

    UNION ALL

    SELECT 'screening_layer', count(*)
    FROM iris_core.screening_layer

    UNION ALL

    SELECT 'evidence', count(*)
    FROM iris_core.evidence
) AS counts
ORDER BY entity;

SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'iris_core'
  AND column_name IN (
      'geom',
      'country_code',
      'region_code',
      'source_id',
      'source_date',
      'created_at'
  )
ORDER BY table_name, column_name;

SELECT
    source_id,
    ST_AsText(geom) AS wkt,
    ST_SRID(geom) AS srid,
    ST_Equals(
        geom,
        ST_GeomFromText(ST_AsText(geom), ST_SRID(geom))
    ) AS round_trip_ok
FROM iris_core.substation;

SELECT
    parcel.source_id AS parcel,
    substation.source_id AS substation,
    ROUND(
        ST_Distance(
            parcel.geom::geography,
            substation.geom::geography
        )::numeric,
        2
    ) AS distance_metres
FROM iris_core.parcel AS parcel
JOIN iris_core.substation AS substation
    ON substation.country_code = parcel.country_code
   AND substation.region_code = parcel.region_code
WHERE ST_DWithin(
    parcel.geom::geography,
    substation.geom::geography,
    500
);

SELECT
    parcel.source_id AS parcel,
    peatland.source_id AS peatland,
    ROUND(
        ST_Area(
            ST_Intersection(
                parcel.geom,
                peatland.geom
            )::geography
        )::numeric,
        2
    ) AS overlap_square_metres
FROM iris_core.parcel AS parcel
JOIN iris_core.peatland AS peatland
    ON peatland.country_code = parcel.country_code
   AND peatland.region_code = parcel.region_code
WHERE ST_Intersects(parcel.geom, peatland.geom);

SELECT
    parcel.source_id AS parcel,
    screening.source_id AS screening_layer,
    ROUND(
        ST_Area(
            ST_Intersection(
                parcel.geom,
                screening.geom
            )::geography
        )::numeric,
        2
    ) AS overlap_square_metres
FROM iris_core.parcel AS parcel
JOIN iris_core.screening_layer AS screening
    ON screening.country_code = parcel.country_code
   AND screening.region_code = parcel.region_code
WHERE ST_Intersects(parcel.geom, screening.geom);

SELECT
    source_id,
    evidence_type,
    numeric_value,
    unit,
    uncertainty
FROM iris_core.evidence
ORDER BY evidence_type;

SET enable_seqscan = off;

EXPLAIN (COSTS OFF)
SELECT source_id
FROM iris_core.substation
WHERE ST_DWithin(
    geom::geography,
    ST_SetSRID(
        ST_MakePoint(-1.505, 53.810),
        4326
    )::geography,
    500
);

EXPLAIN (COSTS OFF)
SELECT source_id
FROM iris_core.parcel
WHERE ST_Intersects(
    geom,
    ST_GeomFromText(
        'POLYGON((-1.506 53.804, -1.504 53.804, -1.504 53.806, -1.506 53.806, -1.506 53.804))',
        4326
    )
);

RESET enable_seqscan;
