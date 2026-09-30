CREATE TABLE iris_core.source_run (
    source_run_id bigint GENERATED ALWAYS AS IDENTITY,
    country_code text NOT NULL,
    region_code text NOT NULL,
    source_id text NOT NULL,
    source_date date NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (country_code, source_run_id),
    UNIQUE (country_code, source_id, source_date),

    CHECK (country_code ~ '^[A-Z]{2}$')
);

CREATE TABLE iris_core.parcel (
    parcel_id bigint GENERATED ALWAYS AS IDENTITY,
    country_code text NOT NULL,
    region_code text NOT NULL,
    source_run_id bigint NOT NULL,
    source_id text NOT NULL,
    source_date date NOT NULL,
    completeness_status text NOT NULL,
    geom geometry(MultiPolygon, 4326) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (country_code, parcel_id),
    UNIQUE (country_code, source_id),

    FOREIGN KEY (country_code, source_run_id)
        REFERENCES iris_core.source_run (country_code, source_run_id),

    CHECK (country_code ~ '^[A-Z]{2}$'),
    CHECK (completeness_status IN ('complete', 'partial')),
    CHECK (NOT ST_IsEmpty(geom)),
    CHECK (ST_IsValid(geom))
);

CREATE TABLE iris_core.substation (
    substation_id bigint GENERATED ALWAYS AS IDENTITY,
    country_code text NOT NULL,
    region_code text NOT NULL,
    source_run_id bigint NOT NULL,
    source_id text NOT NULL,
    source_date date NOT NULL,
    name text NOT NULL,
    completeness_status text NOT NULL,
    geom geometry(Point, 4326) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (country_code, substation_id),
    UNIQUE (country_code, source_id),

    FOREIGN KEY (country_code, source_run_id)
        REFERENCES iris_core.source_run (country_code, source_run_id),

    CHECK (country_code ~ '^[A-Z]{2}$'),
    CHECK (completeness_status IN ('complete', 'partial')),
    CHECK (NOT ST_IsEmpty(geom))
);

CREATE TABLE iris_core.peatland (
    peatland_id bigint GENERATED ALWAYS AS IDENTITY,
    country_code text NOT NULL,
    region_code text NOT NULL,
    source_run_id bigint NOT NULL,
    source_id text NOT NULL,
    source_date date NOT NULL,
    classification text,
    completeness_status text NOT NULL,
    geom geometry(MultiPolygon, 4326) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (country_code, peatland_id),
    UNIQUE (country_code, source_id),

    FOREIGN KEY (country_code, source_run_id)
        REFERENCES iris_core.source_run (country_code, source_run_id),

    CHECK (country_code ~ '^[A-Z]{2}$'),
    CHECK (completeness_status IN ('complete', 'partial')),
    CHECK (NOT ST_IsEmpty(geom)),
    CHECK (ST_IsValid(geom))
);

CREATE TABLE iris_core.screening_layer (
    screening_layer_id bigint GENERATED ALWAYS AS IDENTITY,
    country_code text NOT NULL,
    region_code text NOT NULL,
    source_run_id bigint NOT NULL,
    source_id text NOT NULL,
    source_date date NOT NULL,
    name text NOT NULL,
    category text NOT NULL,
    completeness_status text NOT NULL,
    geom geometry(MultiPolygon, 4326) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (country_code, screening_layer_id),
    UNIQUE (country_code, source_id),

    FOREIGN KEY (country_code, source_run_id)
        REFERENCES iris_core.source_run (country_code, source_run_id),

    CHECK (country_code ~ '^[A-Z]{2}$'),
    CHECK (completeness_status IN ('complete', 'partial')),
    CHECK (NOT ST_IsEmpty(geom)),
    CHECK (ST_IsValid(geom))
);

CREATE TABLE iris_core.evidence (
    evidence_id bigint GENERATED ALWAYS AS IDENTITY,
    country_code text NOT NULL,
    region_code text NOT NULL,
    parcel_id bigint NOT NULL,
    source_run_id bigint NOT NULL,
    source_id text NOT NULL,
    source_date date NOT NULL,
    evidence_type text NOT NULL,
    numeric_value numeric NOT NULL,
    unit text NOT NULL,
    uncertainty text NOT NULL,
    substation_id bigint,
    peatland_id bigint,
    screening_layer_id bigint,
    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (country_code, evidence_id),
    UNIQUE (country_code, source_id),

    FOREIGN KEY (country_code, parcel_id)
        REFERENCES iris_core.parcel (country_code, parcel_id),

    FOREIGN KEY (country_code, source_run_id)
        REFERENCES iris_core.source_run (country_code, source_run_id),

    FOREIGN KEY (country_code, substation_id)
        REFERENCES iris_core.substation (country_code, substation_id),

    FOREIGN KEY (country_code, peatland_id)
        REFERENCES iris_core.peatland (country_code, peatland_id),

    FOREIGN KEY (country_code, screening_layer_id)
        REFERENCES iris_core.screening_layer (
            country_code,
            screening_layer_id
        ),

    CHECK (country_code ~ '^[A-Z]{2}$'),
    CHECK (
        num_nonnulls(
            substation_id,
            peatland_id,
            screening_layer_id
        ) = 1
    )
);
