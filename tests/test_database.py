import os
import unittest

import psycopg
from psycopg import errors


class DatabaseTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.connection = psycopg.connect(os.environ["DATABASE_URL"])

    @classmethod
    def tearDownClass(cls):
        cls.connection.close()

    def tearDown(self):
        self.connection.rollback()

    def test_fixture_counts(self):
        expected = {
            "parcel": 2,
            "substation": 1,
            "peatland": 1,
            "screening_layer": 1,
            "evidence": 3,
        }

        for table, count in expected.items():
            with self.subTest(table=table):
                result = self.connection.execute(
                    f"SELECT count(*) FROM iris_core.{table}"
                ).fetchone()
                self.assertEqual(result[0], count)

    def test_evidence_types(self):
        rows = self.connection.execute(
            """
            SELECT evidence_type
            FROM iris_core.evidence
            ORDER BY evidence_type
            """
        ).fetchall()

        self.assertEqual(
            [row[0] for row in rows],
            [
                "peatland_overlap",
                "screening_overlap",
                "substation_distance",
            ],
        )

    def test_fixture_spatial_relationships(self):
        result = self.connection.execute(
            """
            SELECT
                (
                    SELECT count(*)
                    FROM iris_core.parcel AS parcel
                    JOIN iris_core.substation AS substation
                        ON substation.country_code = parcel.country_code
                       AND substation.region_code = parcel.region_code
                    WHERE ST_DWithin(
                        parcel.geom::geography,
                        substation.geom::geography,
                        500
                    )
                ),
                (
                    SELECT count(*)
                    FROM iris_core.parcel AS parcel
                    JOIN iris_core.peatland AS peatland
                        ON peatland.country_code = parcel.country_code
                       AND peatland.region_code = parcel.region_code
                    WHERE ST_Intersects(parcel.geom, peatland.geom)
                ),
                (
                    SELECT count(*)
                    FROM iris_core.parcel AS parcel
                    JOIN iris_core.screening_layer AS screening
                        ON screening.country_code = parcel.country_code
                       AND screening.region_code = parcel.region_code
                    WHERE ST_Intersects(parcel.geom, screening.geom)
                )
            """
        ).fetchone()

        self.assertEqual(result, (1, 1, 1))

    def test_null_country_code_is_rejected(self):
        with self.assertRaises(errors.NotNullViolation):
            self.connection.execute(
                """
                INSERT INTO iris_core.parcel (
                    country_code,
                    region_code,
                    source_run_id,
                    source_id,
                    source_date,
                    completeness_status,
                    geom
                )
                SELECT
                    NULL,
                    'GB-DEMO',
                    source_run_id,
                    'NULL-COUNTRY',
                    DATE '2026-01-01',
                    'complete',
                    ST_GeomFromText(
                        'MULTIPOLYGON(((-1 53, 0 53, 0 54, -1 54, -1 53)))',
                        4326
                    )
                FROM iris_core.source_run
                WHERE country_code = 'GB'
                  AND source_id = 'fixture-parcels'
                """
            )

    def test_cross_country_reference_is_rejected(self):
        with self.assertRaises(errors.ForeignKeyViolation):
            self.connection.execute(
                """
                INSERT INTO iris_core.parcel (
                    country_code,
                    region_code,
                    source_run_id,
                    source_id,
                    source_date,
                    completeness_status,
                    geom
                )
                SELECT
                    'IN',
                    'IN-DEMO',
                    source_run_id,
                    'CROSS-COUNTRY',
                    DATE '2026-01-01',
                    'complete',
                    ST_GeomFromText(
                        'MULTIPOLYGON(((77 12, 78 12, 78 13, 77 13, 77 12)))',
                        4326
                    )
                FROM iris_core.source_run
                WHERE country_code = 'GB'
                  AND source_id = 'fixture-parcels'
                """
            )

    def test_duplicate_country_source_id_is_rejected(self):
        with self.assertRaises(errors.UniqueViolation):
            self.connection.execute(
                """
                INSERT INTO iris_core.parcel (
                    country_code,
                    region_code,
                    source_run_id,
                    source_id,
                    source_date,
                    completeness_status,
                    geom
                )
                SELECT
                    'GB',
                    'GB-DEMO',
                    source_run_id,
                    'PARCEL-001',
                    DATE '2026-01-01',
                    'complete',
                    ST_GeomFromText(
                        'MULTIPOLYGON(((-1 53, 0 53, 0 54, -1 54, -1 53)))',
                        4326
                    )
                FROM iris_core.source_run
                WHERE country_code = 'GB'
                  AND source_id = 'fixture-parcels'
                """
            )

    def test_wrong_geometry_type_is_rejected(self):
        with self.assertRaises(psycopg.Error):
            self.connection.execute(
                """
                INSERT INTO iris_core.substation (
                    country_code,
                    region_code,
                    source_run_id,
                    source_id,
                    source_date,
                    name,
                    completeness_status,
                    geom
                )
                SELECT
                    'GB',
                    'GB-DEMO',
                    source_run_id,
                    'WRONG-TYPE',
                    DATE '2026-01-01',
                    'Wrong Type',
                    'complete',
                    ST_GeomFromText(
                        'POLYGON((-1 53, 0 53, 0 54, -1 54, -1 53))',
                        4326
                    )
                FROM iris_core.source_run
                WHERE country_code = 'GB'
                  AND source_id = 'fixture-substations'
                """
            )

    def test_wrong_srid_is_rejected(self):
        with self.assertRaises(psycopg.Error):
            self.connection.execute(
                """
                INSERT INTO iris_core.parcel (
                    country_code,
                    region_code,
                    source_run_id,
                    source_id,
                    source_date,
                    completeness_status,
                    geom
                )
                SELECT
                    'GB',
                    'GB-DEMO',
                    source_run_id,
                    'WRONG-SRID',
                    DATE '2026-01-01',
                    'complete',
                    ST_GeomFromText(
                        'MULTIPOLYGON(((0 0, 1 0, 1 1, 0 1, 0 0)))',
                        3857
                    )
                FROM iris_core.source_run
                WHERE country_code = 'GB'
                  AND source_id = 'fixture-parcels'
                """
            )


if __name__ == "__main__":
    unittest.main()
