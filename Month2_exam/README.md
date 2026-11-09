# Month 2 Practical Project: Social Media Intelligence Database

This project demonstrates a small relational database for storing social-media platforms, accounts, username history, posts, and individual interaction events.

The implementation uses only Python's standard library and SQLite. No external package is required.

## Data model

The database has five tables:

1. **platforms** - one row per social platform.
2. **accounts** - one stable internal account ID per account on a platform.
3. **account_username_history** - current and historical usernames for an account.
4. **posts** - posts authored by accounts.
5. **interactions** - individual Like, Reply, Repost, and Quote events.

### Relationships

- One platform has many accounts.
- One account has many username-history rows over time.
- One account has many authored posts.
- One account can perform many interactions.
- One post can receive many interactions.
- An interaction's actor and target post must belong to the same platform in this version of the model.

## Identity and username changes

account_id is the stable internal identity. It does not change when a username changes.

When the platform provides a stable platform_user_id, that ID is the primary matching key within the platform. A username change creates a new row in account_username_history; the previous row receives a valid_to timestamp. Posts and interactions continue to reference the same account_id.

If the native platform ID is unavailable, the helper can reuse an already-current username. This is a weaker match because platforms may recycle usernames. A collision with a different known platform ID raises IdentityConflictError; the code does not silently merge the accounts.

For a manually verified identity match without a native platform ID, call register_account with verified_existing_account_id. Do not use that parameter unless the identity has been checked using reliable evidence.

valid_from is the first known observation time in this sample implementation. It is not necessarily the exact historical date on which the platform username changed. evidence_source records where the identity/username evidence came from.

## Timestamp policy

All timestamps are stored as UTC ISO-8601 text, for example:

    2026-11-06T10:00:00Z

The model distinguishes:
- published_at: when the post was published.
- interacted_at: when the interaction happened.
- ingested_at: when the record entered this database.
- first_seen_at and last_seen_at: when an account was first and most recently observed.
- first_observed_at and last_observed_at: when a username was observed.

Do not replace an unknown publication or interaction time with the current ingestion time.

## Data integrity

- Primary keys identify internal records.
- Foreign keys connect related records.
- Composite foreign keys ensure an interaction actor and its target post belong to the same platform.
- Partial unique indexes prevent duplicate known platform user IDs and duplicate current usernames on the same platform.
- A partial unique index permits only one current username per account.
- CHECK constraints restrict interaction types and reject empty required text values.
- External post and interaction IDs are unique within a platform when they are available.

If an interaction has no platform-native event ID, exact event-level deduplication cannot always be guaranteed. The schema does not impose a unique actor/post/type rule because a user may legitimately reply or quote the same post more than once.

## Five analytical queries

queries.sql contains exactly five named queries:

1. daily_post_counts - number of posts per UTC day.
2. top_5_accounts_by_post_count - accounts with the most authored posts.
3. posts_without_interactions - posts with no interaction records.
4. interaction_type_distribution_by_platform - interaction-type counts by platform.
5. top_5_posts_by_unique_interacting_accounts - posts ranked by distinct interacting accounts.

## Synthetic sample data

seed.sql inserts:
- 3 platforms.
- 10 accounts.
- 11 username-history rows, including one verified username change.
- 20 posts.
- 36 individual interaction events.

All sample content and identities are fictional.

## Run the project

Run these commands from the Month2_exam directory.

### Initialize schema and load sample data

Windows PowerShell:

    python db.py init --seed

macOS Terminal:

    python3 db.py init --seed

### Run one query

    python db.py query daily_post_counts

Other query names are listed with:

    python db.py list-queries

Run all five queries:

    python db.py all

The default database file is created at data/social_media_intelligence.db.

### Run tests

Windows PowerShell:

    python -m unittest discover -s tests -v

macOS Terminal:

    python3 -m unittest discover -s tests -v

The tests use a temporary database and do not modify the demonstration database.

## Example: record a username change

The register_account function in db.py first looks for a matching platform-native user ID. If it finds the same account with a new username, it closes the old username-history row and inserts the new one while keeping the same account_id.

A simplified call looks like this:

    account_id = register_account(
        connection,
        platform_id=1,
        platform_user_id="x-1001",
        username="@ali_new",
        observed_at="2026-11-06T10:00:00Z",
        evidence_source="platform_user_id",
    )

The function uses a savepoint so that a failed identity or username update does not leave half-applied changes.

## Git workflow

From the repository root:

    git status
    git switch month2-exam
    git pull --ff-only origin month2-exam
    git add Month2_exam
    git commit -m "Add Month 2 SQLite database project"
    git push -u origin month2-exam

This project is a learning and portfolio exercise. The sample data is synthetic and is not intended for production ingestion without additional validation, logging, migrations, and privacy controls.
