CREATE TABLE iris_staging.feature (
    staging_feature_id bigint GENERATED ALWAYS AS IDENTITY,
    country_code text NOT NULL,
    region_code text NOT NULL,
    source_run_id bigint NOT NULL,
    source_id text NOT NULL,
    source_date date NOT NULL,
    feature_type text NOT NULL,
    name text,
    category text,
    classification text,
    completeness_status text NOT NULL,
    source_srid integer NOT NULL,
    geom geometry(Geometry) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (country_code, staging_feature_id),
    UNIQUE (country_code, feature_type, source_id),

    FOREIGN KEY (country_code, source_run_id)
        REFERENCES iris_core.source_run (country_code, source_run_id),

    CHECK (country_code ~ '^[A-Z]{2}$'),
    CHECK (
        feature_type IN (
            'parcel',
            'substation',
            'peatland',
            'screening_layer'
        )
    ),
    CHECK (completeness_status IN ('complete', 'partial')),
    CHECK (source_srid > 0),
    CHECK (ST_SRID(geom) = source_srid),
    CHECK (NOT ST_IsEmpty(geom))
);
