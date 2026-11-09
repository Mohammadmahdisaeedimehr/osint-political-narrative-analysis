"""SQLite utilities for the Month 2 Social Media Intelligence exam."""

from __future__ import annotations

import argparse
import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

BASE_DIR = Path(__file__).resolve().parent
DEFAULT_DB_PATH = BASE_DIR / "data" / "social_media_intelligence.db"
SCHEMA_PATH = BASE_DIR / "schema.sql"
SEED_PATH = BASE_DIR / "seed.sql"
QUERIES_PATH = BASE_DIR / "queries.sql"


class IdentityConflictError(ValueError):
    """Raised when identity evidence is insufficient or conflicts with stored data."""


def normalize_utc_timestamp(value: str) -> str:
    """Validate a timezone-aware timestamp and normalize it to UTC ISO-8601."""
    if not isinstance(value, str) or not value.strip():
        raise ValueError("A non-empty UTC timestamp is required.")

    try:
        parsed = datetime.fromisoformat(value.strip().replace("Z", "+00:00"))
    except ValueError as exc:
        raise ValueError(f"Invalid ISO-8601 timestamp: {value}") from exc

    if parsed.tzinfo is None or parsed.utcoffset() is None:
        raise ValueError("Timestamp must include a timezone, preferably UTC (Z).")

    normalized = parsed.astimezone(timezone.utc)
    return normalized.isoformat(timespec="seconds").replace("+00:00", "Z")


def get_connection(db_path: str | Path = DEFAULT_DB_PATH) -> sqlite3.Connection:
    """Open a SQLite connection with foreign-key enforcement enabled."""
    db_path_text = str(db_path)

    if db_path_text != ":memory:":
        Path(db_path_text).expanduser().resolve().parent.mkdir(
            parents=True, exist_ok=True
        )

    connection = sqlite3.connect(db_path_text)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")
    connection.execute("PRAGMA busy_timeout = 5000")
    return connection


def execute_sql_file(connection: sqlite3.Connection, file_path: str | Path) -> None:
    """Execute a UTF-8 SQL file against an existing connection."""
    sql_path = Path(file_path)
    if not sql_path.exists():
        raise FileNotFoundError(f"SQL file not found: {sql_path}")
    connection.executescript(sql_path.read_text(encoding="utf-8"))


def initialize_database(
    connection: sqlite3.Connection, schema_path: str | Path = SCHEMA_PATH
) -> None:
    """Create all tables and indexes."""
    execute_sql_file(connection, schema_path)


def load_seed_data(
    connection: sqlite3.Connection, seed_path: str | Path = SEED_PATH
) -> None:
    """Insert the synthetic sample dataset."""
    execute_sql_file(connection, seed_path)


def load_queries(queries_path: str | Path = QUERIES_PATH) -> dict[str, str]:
    """Load named SQL sections from queries.sql."""
    path = Path(queries_path)
    if not path.exists():
        raise FileNotFoundError(f"Query file not found: {path}")

    queries: dict[str, str] = {}
    current_name: str | None = None
    current_lines: list[str] = []

    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("-- name:"):
            if current_name is not None:
                statement = "\n".join(current_lines).strip()
                if statement:
                    queries[current_name] = statement
            current_name = line.split(":", 1)[1].strip()
            if not current_name:
                raise ValueError("A query name cannot be empty.")
            current_lines = []
        elif current_name is not None:
            current_lines.append(line)

    if current_name is not None:
        statement = "\n".join(current_lines).strip()
        if statement:
            queries[current_name] = statement

    if not queries:
        raise ValueError(f"No named queries found in {path}")

    return queries


def run_query(
    connection: sqlite3.Connection,
    query_name: str,
    queries_path: str | Path = QUERIES_PATH,
) -> list[dict[str, Any]]:
    """Execute one named query and return rows as dictionaries."""
    queries = load_queries(queries_path)
    if query_name not in queries:
        available = ", ".join(sorted(queries))
        raise KeyError(f"Unknown query '{query_name}'. Available queries: {available}")

    cursor = connection.execute(queries[query_name])
    return [dict(row) for row in cursor.fetchall()]


def run_all_queries(
    connection: sqlite3.Connection, queries_path: str | Path = QUERIES_PATH
) -> dict[str, list[dict[str, Any]]]:
    """Execute every named query in queries.sql."""
    return {
        name: run_query(connection, name, queries_path)
        for name in load_queries(queries_path)
    }


def register_account(
    connection: sqlite3.Connection,
    *,
    platform_id: int,
    username: str | None,
    observed_at: str,
    platform_user_id: str | None = None,
    verified_existing_account_id: int | None = None,
    evidence_source: str = "initial_observation",
) -> int:
    """Find or create an account and preserve username changes as history.

    Matching priority:
    1. A matching platform-native user ID.
    2. An explicitly verified existing account ID.
    3. A currently assigned username, only when no platform-native ID is supplied.

    A username collision with a different platform-native ID raises
    IdentityConflictError instead of silently merging two accounts.
    """
    timestamp = normalize_utc_timestamp(observed_at)
    clean_username = username.strip() if username and username.strip() else None
    clean_platform_user_id = (
        platform_user_id.strip()
        if platform_user_id and platform_user_id.strip()
        else None
    )

    if clean_username is not None and not evidence_source.strip():
        raise ValueError("evidence_source is required when a username is supplied.")

    connection.execute("SAVEPOINT register_account")
    try:
        platform = connection.execute(
            "SELECT platform_id FROM platforms WHERE platform_id = ?",
            (platform_id,),
        ).fetchone()
        if platform is None:
            raise ValueError(f"Unknown platform_id: {platform_id}")

        account = None
        if clean_platform_user_id is not None:
            account = connection.execute(
                """
                SELECT account_id, platform_user_id
                FROM accounts
                WHERE platform_id = ? AND platform_user_id = ?
                """,
                (platform_id, clean_platform_user_id),
            ).fetchone()

        if verified_existing_account_id is not None:
            verified_account = connection.execute(
                """
                SELECT account_id, platform_id, platform_user_id
                FROM accounts
                WHERE account_id = ?
                """,
                (verified_existing_account_id,),
            ).fetchone()
            if verified_account is None or verified_account["platform_id"] != platform_id:
                raise IdentityConflictError(
                    "The verified account does not exist on the requested platform."
                )
            if account is not None and account["account_id"] != verified_existing_account_id:
                raise IdentityConflictError(
                    "The platform user ID belongs to a different account."
                )
            if (
                clean_platform_user_id is not None
                and verified_account["platform_user_id"] not in (None, clean_platform_user_id)
            ):
                raise IdentityConflictError(
                    "The verified account already has a different platform user ID."
                )
            account_id = verified_existing_account_id
            if clean_platform_user_id is not None:
                connection.execute(
                    """
                    UPDATE accounts
                    SET platform_user_id = ?
                    WHERE account_id = ? AND platform_user_id IS NULL
                    """,
                    (clean_platform_user_id, account_id),
                )
        elif account is not None:
            account_id = account["account_id"]
        elif clean_username is not None:
            current_name = connection.execute(
                """
                SELECT h.account_id, a.platform_user_id
                FROM account_username_history AS h
                JOIN accounts AS a ON a.account_id = h.account_id
                WHERE h.platform_id = ?
                  AND h.username = ?
                  AND h.valid_to IS NULL
                """,
                (platform_id, clean_username),
            ).fetchone()

            if current_name is not None:
                if (
                    clean_platform_user_id is not None
                    and current_name["platform_user_id"] != clean_platform_user_id
                ):
                    raise IdentityConflictError(
                        "This current username is already attached to another identity. "
                        "Verify the account before reusing or merging it."
                    )
                account_id = current_name["account_id"]
            else:
                cursor = connection.execute(
                    """
                    INSERT INTO accounts
                        (platform_id, platform_user_id, first_seen_at,
                         last_seen_at, created_at)
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    (
                        platform_id,
                        clean_platform_user_id,
                        timestamp,
                        timestamp,
                        timestamp,
                    ),
                )
                account_id = int(cursor.lastrowid)
        elif clean_platform_user_id is not None:
            cursor = connection.execute(
                """
                INSERT INTO accounts
                    (platform_id, platform_user_id, first_seen_at,
                     last_seen_at, created_at)
                VALUES (?, ?, ?, ?, ?)
                """,
                (
                    platform_id,
                    clean_platform_user_id,
                    timestamp,
                    timestamp,
                    timestamp,
                ),
            )
            account_id = int(cursor.lastrowid)
        else:
            raise ValueError("Provide a username or a platform_user_id.")

        existing_account = connection.execute(
            """
            SELECT platform_user_id
            FROM accounts
            WHERE account_id = ? AND platform_id = ?
            """,
            (account_id, platform_id),
        ).fetchone()
        if existing_account is None:
            raise IdentityConflictError("Resolved account does not belong to this platform.")

        if clean_platform_user_id is not None:
            stored_platform_user_id = existing_account["platform_user_id"]
            if stored_platform_user_id not in (None, clean_platform_user_id):
                raise IdentityConflictError(
                    "The resolved account has a different platform user ID."
                )
            if stored_platform_user_id is None:
                connection.execute(
                    "UPDATE accounts SET platform_user_id = ? WHERE account_id = ?",
                    (clean_platform_user_id, account_id),
                )

        connection.execute(
            """
            UPDATE accounts
            SET first_seen_at = CASE
                    WHEN first_seen_at > ? THEN ? ELSE first_seen_at END,
                last_seen_at = CASE
                    WHEN last_seen_at < ? THEN ? ELSE last_seen_at END
            WHERE account_id = ?
            """,
            (timestamp, timestamp, timestamp, timestamp, account_id),
        )

        if clean_username is not None:
            current_username = connection.execute(
                """
                SELECT username_history_id, username, valid_from
                FROM account_username_history
                WHERE account_id = ? AND valid_to IS NULL
                """,
                (account_id,),
            ).fetchone()

            username_owner = connection.execute(
                """
                SELECT account_id
                FROM account_username_history
                WHERE platform_id = ? AND username = ? AND valid_to IS NULL
                """,
                (platform_id, clean_username),
            ).fetchone()
            if username_owner is not None and username_owner["account_id"] != account_id:
                raise IdentityConflictError(
                    "The username is currently assigned to another account."
                )

            if current_username is not None and current_username["username"].casefold() == clean_username.casefold():
                connection.execute(
                    """
                    UPDATE account_username_history
                    SET last_observed_at = CASE
                        WHEN last_observed_at < ? THEN ? ELSE last_observed_at END
                    WHERE username_history_id = ?
                    """,
                    (
                        timestamp,
                        timestamp,
                        current_username["username_history_id"],
                    ),
                )
            else:
                if current_username is not None:
                    if timestamp <= current_username["valid_from"]:
                        raise ValueError(
                            "A username change must be observed after the current "
                            "username's valid_from timestamp."
                        )
                    connection.execute(
                        """
                        UPDATE account_username_history
                        SET valid_to = ?
                        WHERE username_history_id = ?
                        """,
                        (timestamp, current_username["username_history_id"]),
                    )

                connection.execute(
                    """
                    INSERT INTO account_username_history
                        (account_id, platform_id, username, first_observed_at,
                         last_observed_at, valid_from, valid_to, evidence_source)
                    VALUES (?, ?, ?, ?, ?, ?, NULL, ?)
                    """,
                    (
                        account_id,
                        platform_id,
                        clean_username,
                        timestamp,
                        timestamp,
                        timestamp,
                        evidence_source.strip(),
                    ),
                )

        connection.execute("RELEASE SAVEPOINT register_account")
        return account_id
    except Exception:
        connection.execute("ROLLBACK TO SAVEPOINT register_account")
        connection.execute("RELEASE SAVEPOINT register_account")
        raise


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run the Month 2 SQLite social-media database."
    )
    parser.add_argument(
        "--db",
        default=str(DEFAULT_DB_PATH),
        help="SQLite database path (default: Month2_exam/data/social_media_intelligence.db)",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    init_parser = subparsers.add_parser("init", help="Create the database schema.")
    init_parser.add_argument(
        "--seed", action="store_true", help="Load the synthetic sample data after initialization."
    )
    subparsers.add_parser("seed", help="Load the synthetic sample data.")
    query_parser = subparsers.add_parser("query", help="Run one named SQL query.")
    query_parser.add_argument("name", help="Query name from queries.sql.")
    subparsers.add_parser("all", help="Run all five SQL queries.")
    subparsers.add_parser("list-queries", help="List available query names.")

    args = parser.parse_args()

    try:
        if args.command == "list-queries":
            for query_name in sorted(load_queries()):
                print(query_name)
            return 0

        with get_connection(args.db) as connection:
            if args.command == "init":
                initialize_database(connection)
                if args.seed:
                    load_seed_data(connection)
                print(f"Database initialized: {args.db}")
                if args.seed:
                    print("Synthetic seed data loaded.")
            elif args.command == "seed":
                load_seed_data(connection)
                print("Synthetic seed data loaded.")
            elif args.command == "query":
                rows = run_query(connection, args.name)
                print(json.dumps(rows, ensure_ascii=False, indent=2))
            elif args.command == "all":
                results = run_all_queries(connection)
                print(json.dumps(results, ensure_ascii=False, indent=2))
        return 0
    except (sqlite3.Error, OSError, ValueError, KeyError) as exc:
        print(f"Error: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
