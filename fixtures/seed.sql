BEGIN;

INSERT INTO iris_core.source_run (
    country_code,
    region_code,
    source_id,
    source_date,
    created_at
)
VALUES
    (
        'GB',
        'GB-DEMO',
        'fixture-parcels',
        DATE '2026-01-01',
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    ),
    (
        'GB',
        'GB-DEMO',
        'fixture-substations',
        DATE '2026-01-01',
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    ),
    (
        'GB',
        'GB-DEMO',
        'fixture-peatlands',
        DATE '2026-01-01',
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    ),
    (
        'GB',
        'GB-DEMO',
        'fixture-screening',
        DATE '2026-01-01',
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    );

INSERT INTO iris_staging.feature (
    country_code,
    region_code,
    source_run_id,
    source_id,
    source_date,
    feature_type,
    name,
    category,
    classification,
    completeness_status,
    source_srid,
    geom,
    created_at
)
VALUES
    (
        'GB',
        'GB-DEMO',
        (
            SELECT source_run_id
            FROM iris_core.source_run
            WHERE country_code = 'GB'
              AND source_id = 'fixture-parcels'
              AND source_date = DATE '2026-01-01'
        ),
        'PARCEL-001',
        DATE '2026-01-01',
        'parcel',
        NULL,
        NULL,
        NULL,
        'complete',
        4326,
        ST_GeomFromText(
            'MULTIPOLYGON(((-1.510 53.800, -1.500 53.800, -1.500 53.810, -1.510 53.810, -1.510 53.800)))',
            4326
        ),
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    ),
    (
        'GB',
        'GB-DEMO',
        (
            SELECT source_run_id
            FROM iris_core.source_run
            WHERE country_code = 'GB'
              AND source_id = 'fixture-parcels'
              AND source_date = DATE '2026-01-01'
        ),
        'PARCEL-002',
        DATE '2026-01-01',
        'parcel',
        NULL,
        NULL,
        NULL,
        'complete',
        4326,
        ST_GeomFromText(
            'MULTIPOLYGON(((-1.490 53.800, -1.480 53.800, -1.480 53.810, -1.490 53.810, -1.490 53.800)))',
            4326
        ),
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    ),
    (
        'GB',
        'GB-DEMO',
        (
            SELECT source_run_id
            FROM iris_core.source_run
            WHERE country_code = 'GB'
              AND source_id = 'fixture-substations'
              AND source_date = DATE '2026-01-01'
        ),
        'SUBSTATION-001',
        DATE '2026-01-01',
        'substation',
        'Demo Substation',
        NULL,
        NULL,
        'complete',
        4326,
        ST_GeomFromText('POINT(-1.505 53.812)', 4326),
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    ),
    (
        'GB',
        'GB-DEMO',
        (
            SELECT source_run_id
            FROM iris_core.source_run
            WHERE country_code = 'GB'
              AND source_id = 'fixture-peatlands'
              AND source_date = DATE '2026-01-01'
        ),
        'PEATLAND-001',
        DATE '2026-01-01',
        'peatland',
        NULL,
        NULL,
        NULL,
        'partial',
        4326,
        ST_GeomFromText(
            'MULTIPOLYGON(((-1.505 53.805, -1.495 53.805, -1.495 53.815, -1.505 53.815, -1.505 53.805)))',
            4326
        ),
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    ),
    (
        'GB',
        'GB-DEMO',
        (
            SELECT source_run_id
            FROM iris_core.source_run
            WHERE country_code = 'GB'
              AND source_id = 'fixture-screening'
              AND source_date = DATE '2026-01-01'
        ),
        'SCREENING-001',
        DATE '2026-01-01',
        'screening_layer',
        'Demo Constraint',
        'constraint',
        NULL,
        'complete',
        4326,
        ST_GeomFromText(
            'MULTIPOLYGON(((-1.485 53.805, -1.475 53.805, -1.475 53.815, -1.485 53.815, -1.485 53.805)))',
            4326
        ),
        TIMESTAMPTZ '2026-01-01 00:00:00+00'
    );

COMMIT;
