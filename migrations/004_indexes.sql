CREATE INDEX parcel_geom_idx
    ON iris_core.parcel
    USING GIST (geom);

CREATE INDEX substation_geography_idx
    ON iris_core.substation
    USING GIST ((geom::geography));

CREATE INDEX peatland_geom_idx
    ON iris_core.peatland
    USING GIST (geom);

CREATE INDEX screening_layer_geom_idx
    ON iris_core.screening_layer
    USING GIST (geom);

CREATE INDEX parcel_country_region_idx
    ON iris_core.parcel (country_code, region_code);

CREATE INDEX substation_country_region_idx
    ON iris_core.substation (country_code, region_code);

CREATE INDEX peatland_country_region_idx
    ON iris_core.peatland (country_code, region_code);

CREATE INDEX screening_layer_country_region_idx
    ON iris_core.screening_layer (country_code, region_code);

CREATE INDEX evidence_parcel_idx
    ON iris_core.evidence (country_code, parcel_id);
