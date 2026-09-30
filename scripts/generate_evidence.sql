BEGIN;

INSERT INTO iris_core.source_run (
    country_code,
    region_code,
    source_id,
    source_date,
    created_at
)
VALUES (
    'GB',
    'GB-DEMO',
    'fixture-analysis',
    DATE '2026-01-01',
    TIMESTAMPTZ '2026-01-01 00:05:00+00'
);

INSERT INTO iris_core.evidence (
    country_code,
    region_code,
    parcel_id,
    source_run_id,
    source_id,
    source_date,
    evidence_type,
    numeric_value,
    unit,
    uncertainty,
    substation_id,
    peatland_id,
    screening_layer_id,
    created_at
)
SELECT
    parcel.country_code,
    parcel.region_code,
    parcel.parcel_id,
    analysis.source_run_id,
    parcel.source_id || ':distance:' || substation.source_id,
    DATE '2026-01-01',
    'substation_distance',
    ROUND(
        ST_Distance(
            parcel.geom::geography,
            substation.geom::geography
        )::numeric,
        2
    ),
    'metre',
    'illustrative fixture geometry',
    substation.substation_id,
    NULL,
    NULL,
    TIMESTAMPTZ '2026-01-01 00:05:00+00'
FROM iris_core.parcel AS parcel
JOIN iris_core.substation AS substation
    ON substation.country_code = parcel.country_code
   AND substation.region_code = parcel.region_code
JOIN iris_core.source_run AS analysis
    ON analysis.country_code = parcel.country_code
   AND analysis.source_id = 'fixture-analysis'
   AND analysis.source_date = DATE '2026-01-01'
WHERE ST_DWithin(
    parcel.geom::geography,
    substation.geom::geography,
    500
);

INSERT INTO iris_core.evidence (
    country_code,
    region_code,
    parcel_id,
    source_run_id,
    source_id,
    source_date,
    evidence_type,
    numeric_value,
    unit,
    uncertainty,
    substation_id,
    peatland_id,
    screening_layer_id,
    created_at
)
SELECT
    parcel.country_code,
    parcel.region_code,
    parcel.parcel_id,
    analysis.source_run_id,
    parcel.source_id || ':peatland:' || peatland.source_id,
    DATE '2026-01-01',
    'peatland_overlap',
    ROUND(
        ST_Area(
            ST_Intersection(
                parcel.geom,
                peatland.geom
            )::geography
        )::numeric,
        2
    ),
    'square_metre',
    'illustrative fixture geometry',
    NULL,
    peatland.peatland_id,
    NULL,
    TIMESTAMPTZ '2026-01-01 00:05:00+00'
FROM iris_core.parcel AS parcel
JOIN iris_core.peatland AS peatland
    ON peatland.country_code = parcel.country_code
   AND peatland.region_code = parcel.region_code
JOIN iris_core.source_run AS analysis
    ON analysis.country_code = parcel.country_code
   AND analysis.source_id = 'fixture-analysis'
   AND analysis.source_date = DATE '2026-01-01'
WHERE ST_Intersects(parcel.geom, peatland.geom);

INSERT INTO iris_core.evidence (
    country_code,
    region_code,
    parcel_id,
    source_run_id,
    source_id,
    source_date,
    evidence_type,
    numeric_value,
    unit,
    uncertainty,
    substation_id,
    peatland_id,
    screening_layer_id,
    created_at
)
SELECT
    parcel.country_code,
    parcel.region_code,
    parcel.parcel_id,
    analysis.source_run_id,
    parcel.source_id || ':screening:' || screening.source_id,
    DATE '2026-01-01',
    'screening_overlap',
    ROUND(
        ST_Area(
            ST_Intersection(
                parcel.geom,
                screening.geom
            )::geography
        )::numeric,
        2
    ),
    'square_metre',
    'illustrative fixture geometry',
    NULL,
    NULL,
    screening.screening_layer_id,
    TIMESTAMPTZ '2026-01-01 00:05:00+00'
FROM iris_core.parcel AS parcel
JOIN iris_core.screening_layer AS screening
    ON screening.country_code = parcel.country_code
   AND screening.region_code = parcel.region_code
JOIN iris_core.source_run AS analysis
    ON analysis.country_code = parcel.country_code
   AND analysis.source_id = 'fixture-analysis'
   AND analysis.source_date = DATE '2026-01-01'
WHERE ST_Intersects(parcel.geom, screening.geom);

COMMIT;
