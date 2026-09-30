# IRIS-CAND-03

Minimal PostgreSQL/PostGIS schema for the IRIS pilot. The project demonstrates country-scoped data modelling, staged spatial imports, BESS proximity screening, peatland overlap analysis, and traceable evidence.

## Requirements

- Docker
- Docker Compose v2
- Make

The containers provide:

- PostgreSQL 16
- PostGIS 3.4
- Python 3.12

## Quick start

Build the database from an empty state:

```bash
make rebuild
```

Run the verification queries:

```bash
make verify
```

Run the automated tests:

```bash
make test
```

Stop the containers:

```bash
make down
```

## Rebuild process

`make rebuild` performs these steps:

1. Starts PostgreSQL/PostGIS.
2. Drops the existing `iris_staging` and `iris_core` schemas.
3. Applies the numbered migrations.
4. Loads deterministic fixture data into staging.
5. Validates and promotes spatial features into core.
6. Calculates and stores evidence.

## Project structure

```text
migrations/       Database schemas, tables, constraints, and indexes
fixtures/         Deterministic fixture data
scripts/          Reset, promotion, and evidence generation SQL
verification/     Spatial queries and query-plan checks
tests/            Automated database tests
docs/             Mermaid source and rendered schema diagram
compose.yaml      PostgreSQL/PostGIS and test services
Dockerfile        Python 3.12 environment for running automated tests
Makefile          Reproducible project commands
```

## Data flow

```text
source_run
    ↓
iris_staging.feature
    ↓ validation and CRS transformation
iris_core spatial tables
    ↓ spatial calculations
iris_core.evidence
```

`iris_staging.feature` accepts the four supported feature types:

- `parcel`
- `substation`
- `peatland`
- `screening_layer`

Valid staging records are promoted into the corresponding core table. Invalid records remain in staging.

## Core schema

The core schema contains:

- `source_run`
- `parcel`
- `substation`
- `peatland`
- `screening_layer`
- `evidence`

Every persisted entity has a non-null `country_code`. Primary keys, unique constraints, foreign keys, and joins are country-scoped.

The schema diagram is available in:

- `docs/schema.md`
- `docs/schema.mmd`
- `docs/schema-diagram.png`

## CRS policy

Core geometries are stored in EPSG:4326.

| Entity | Geometry |
|---|---|
| Parcel | `MultiPolygon` |
| Substation | `Point` |
| Peatland | `MultiPolygon` |
| Screening layer | `MultiPolygon` |

Incoming staging geometries must have a known SRID. `source_srid` must match the geometry's PostGIS SRID. Promotion accepts only valid 2D geometries of the expected type and transforms them to EPSG:4326 with `ST_Transform`.

Missing or unknown CRS information must not be assigned by assumption.

EPSG:4326 coordinates are angular degrees, so distances and areas are not measured directly on the stored geometry. The pilot casts geometries to `geography` for results in metres and square metres.

Fixture coordinates use longitude first and latitude second.

## Pilot evidence

The fixture analysis produces three evidence types:

| Evidence type | Calculation | Unit |
|---|---|---|
| `substation_distance` | Shortest parcel-to-substation distance | metre |
| `peatland_overlap` | Parcel and peatland intersection area | square metre |
| `screening_overlap` | Parcel and screening-layer intersection area | square metre |

Substation evidence is generated only for parcel/substation pairs within 500 metres. This threshold is an illustrative fixture assumption, not a BESS suitability rule.

Evidence records store measurements and provenance. They do not represent planning approval, construction readiness, or environmental eligibility.

## Fixtures

The fixture set is fictional and deterministic. It contains:

- Two parcels
- One substation
- One peatland
- One screening layer

The geometries are arranged so that:

- `PARCEL-001` is within 500 metres of `SUBSTATION-001`.
- `PARCEL-001` overlaps `PEATLAND-001`.
- `PARCEL-002` overlaps `SCREENING-001`.

## Indexes

GiST indexes support:

- Parcel intersection searches
- Peatland intersection searches
- Screening-layer intersection searches
- Substation proximity searches using `geography`

B-tree indexes support country/region filtering and evidence-to-parcel joins.

The verification script temporarily disables sequential scans while displaying query plans. This is necessary because PostgreSQL reasonably prefers sequential scans for the very small fixture tables. It demonstrates that the intended spatial indexes are usable; it is not a production setting.

## Tests

`make test` builds the Python 3.12 test container and checks:

- Fixture and evidence counts
- Expected spatial relationships
- Required country codes
- Country-scoped foreign keys
- Country-scoped uniqueness
- Geometry type enforcement
- SRID enforcement

Failed test inserts are rolled back.

## Assumptions and limitations

- `GB-DEMO` is a fictional pilot region.
- Screening layers are modelled as areas.
- `source_id` is unique within an entity table and country.
- An evidence record belongs to one parcel and references exactly one substation, peatland, or screening layer.

## Production evolution

This pilot deliberately keeps the implementation small:

- Numbered SQL migrations are sufficient for the exercise. Production would use a migration tool with recorded migration history.
- Records that fail promotion checks remain in staging. Production would record validation failures and rejection reasons.
- `source_id` is unique by entity type and country. Production would also include a source-system identifier.
- The 500-metre substation threshold is illustrative. Production screening rules would be configurable and versioned.
- Measurements use EPSG:4326 geometries cast to `geography`. Production workflows may use country-specific projected CRSs where required.
- Screening layers are modelled as `MultiPolygon`. Production ingestion would define geometry contracts per source dataset.
