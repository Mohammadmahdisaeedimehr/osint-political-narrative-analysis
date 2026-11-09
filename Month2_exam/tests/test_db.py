"""Automated tests for the Month 2 SQLite database."""

from pathlib import Path
import sqlite3
import tempfile
import unittest
import sys

PROJECT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_DIR))

from db import (  # noqa: E402
    IdentityConflictError,
    get_connection,
    initialize_database,
    load_seed_data,
    register_account,
    run_all_queries,
)


class SocialMediaDatabaseTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.db_path = Path(self.temp_dir.name) / "test_database.sqlite"
        self.connection = get_connection(self.db_path)
        initialize_database(self.connection)
        load_seed_data(self.connection)

    def tearDown(self) -> None:
        self.connection.close()
        self.temp_dir.cleanup()

    def test_foreign_keys_are_enabled(self) -> None:
        enabled = self.connection.execute("PRAGMA foreign_keys").fetchone()[0]
        self.assertEqual(enabled, 1)

    def test_seed_data_has_expected_minimum_counts(self) -> None:
        counts = {
            table: self.connection.execute(
                f"SELECT COUNT(*) FROM {table}"
            ).fetchone()[0]
            for table in (
                "platforms",
                "accounts",
                "account_username_history",
                "posts",
                "interactions",
            )
        }
        self.assertEqual(counts["platforms"], 3)
        self.assertGreaterEqual(counts["accounts"], 8)
        self.assertGreaterEqual(counts["posts"], 20)
        self.assertGreaterEqual(counts["interactions"], 30)

    def test_invalid_post_author_is_rejected(self) -> None:
        with self.assertRaises(sqlite3.IntegrityError):
            self.connection.execute(
                """
                INSERT INTO posts
                    (platform_id, author_account_id, content, published_at, ingested_at)
                VALUES (1, 99999, 'Invalid author', '2026-11-06T10:00:00Z',
                        '2026-11-06T10:01:00Z')
                """
            )

    def test_cross_platform_interaction_is_rejected(self) -> None:
        with self.assertRaises(sqlite3.IntegrityError):
            self.connection.execute(
                """
                INSERT INTO interactions
                    (platform_id, actor_account_id, target_post_id,
                     interaction_type, interacted_at, ingested_at)
                VALUES (1, 6, 1, 'Like', '2026-11-06T10:00:00Z',
                        '2026-11-06T10:01:00Z')
                """
            )

    def test_invalid_interaction_type_is_rejected(self) -> None:
        with self.assertRaises(sqlite3.IntegrityError):
            self.connection.execute(
                """
                INSERT INTO interactions
                    (platform_id, actor_account_id, target_post_id,
                     interaction_type, interacted_at, ingested_at)
                VALUES (1, 2, 1, 'Share', '2026-11-06T10:00:00Z',
                        '2026-11-06T10:01:00Z')
                """
            )

    def test_current_username_must_be_unique_per_platform(self) -> None:
        with self.assertRaises(sqlite3.IntegrityError):
            self.connection.execute(
                """
                INSERT INTO account_username_history
                    (account_id, platform_id, username, first_observed_at,
                     last_observed_at, valid_from, valid_to, evidence_source)
                VALUES (3, 1, '@sara', '2026-11-06T10:00:00Z',
                        '2026-11-06T10:00:00Z', '2026-11-06T10:00:00Z',
                        NULL, 'test')
                """
            )

    def test_platform_user_id_must_be_unique_per_platform(self) -> None:
        with self.assertRaises(sqlite3.IntegrityError):
            self.connection.execute(
                """
                INSERT INTO accounts
                    (platform_id, platform_user_id, first_seen_at,
                     last_seen_at, created_at)
                VALUES (1, 'x-1001', '2026-11-06T10:00:00Z',
                        '2026-11-06T10:00:00Z', '2026-11-06T10:00:00Z')
                """
            )

    def test_registering_same_platform_user_tracks_username_change(self) -> None:
        account_id = register_account(
            self.connection,
            platform_id=1,
            platform_user_id="x-1001",
            username="@ali_renamed",
            observed_at="2026-11-06T10:00:00Z",
            evidence_source="platform_user_id",
        )
        self.assertEqual(account_id, 1)

        old_name = self.connection.execute(
            """
            SELECT valid_to
            FROM account_username_history
            WHERE account_id = 1 AND username = '@ali'
            """
        ).fetchone()
        new_name = self.connection.execute(
            """
            SELECT valid_to
            FROM account_username_history
            WHERE account_id = 1 AND username = '@ali_renamed'
            """
        ).fetchone()

        self.assertEqual(old_name["valid_to"], "2026-11-06T10:00:00Z")
        self.assertIsNone(new_name["valid_to"])

    def test_username_collision_with_different_platform_id_is_not_merged(self) -> None:
        with self.assertRaises(IdentityConflictError):
            register_account(
                self.connection,
                platform_id=1,
                platform_user_id="x-9999",
                username="@sara",
                observed_at="2026-11-06T10:00:00Z",
                evidence_source="profile_snapshot",
            )

    def test_username_lookup_reuses_current_account_when_native_id_is_missing(self) -> None:
        account_id = register_account(
            self.connection,
            platform_id=1,
            platform_user_id=None,
            username="@sara",
            observed_at="2026-11-06T10:00:00Z",
        )
        self.assertEqual(account_id, 2)

    def test_five_queries_return_expected_results(self) -> None:
        results = run_all_queries(self.connection)

        self.assertEqual(set(results), {
            "daily_post_counts",
            "top_5_accounts_by_post_count",
            "posts_without_interactions",
            "interaction_type_distribution_by_platform",
            "top_5_posts_by_unique_interacting_accounts",
        })
        self.assertEqual(sum(row["post_count"] for row in results["daily_post_counts"]), 20)
        self.assertEqual(len(results["top_5_accounts_by_post_count"]), 5)
        self.assertEqual(
            [row["post_id"] for row in results["posts_without_interactions"]],
            [8, 14, 20],
        )
        self.assertEqual(
            sum(row["interaction_count"] for row in results["interaction_type_distribution_by_platform"]),
            36,
        )
        self.assertEqual(len(results["top_5_posts_by_unique_interacting_accounts"]), 5)
        self.assertEqual(
            results["top_5_posts_by_unique_interacting_accounts"][0]["post_id"],
            1,
        )
        self.assertEqual(
            results["top_5_posts_by_unique_interacting_accounts"][0]["unique_interacting_accounts"],
            4,
        )

    def test_seed_script_is_repeatable(self) -> None:
        load_seed_data(self.connection)
        self.assertEqual(
            self.connection.execute("SELECT COUNT(*) FROM posts").fetchone()[0],
            20,
        )


if __name__ == "__main__":
    unittest.main()
