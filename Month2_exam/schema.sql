-- Month 2 exam: Social Media Intelligence Database
-- SQLite schema. All timestamps are stored as UTC ISO-8601 TEXT.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS platforms (
    platform_id INTEGER PRIMARY KEY,
    platform_name TEXT COLLATE NOCASE NOT NULL UNIQUE,
    created_at TEXT NOT NULL,
    CHECK (length(trim(platform_name)) > 0),
    CHECK (length(trim(created_at)) > 0)
);

CREATE TABLE IF NOT EXISTS accounts (
    account_id INTEGER PRIMARY KEY,
    platform_id INTEGER NOT NULL,
    platform_user_id TEXT,
    first_seen_at TEXT NOT NULL,
    last_seen_at TEXT NOT NULL,
    created_at TEXT NOT NULL,
    UNIQUE (account_id, platform_id),
    FOREIGN KEY (platform_id)
        REFERENCES platforms (platform_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CHECK (platform_user_id IS NULL OR length(trim(platform_user_id)) > 0),
    CHECK (last_seen_at >= first_seen_at),
    CHECK (length(trim(first_seen_at)) > 0),
    CHECK (length(trim(last_seen_at)) > 0),
    CHECK (length(trim(created_at)) > 0)
);

-- A platform-native user ID is the strongest account identity key.
CREATE UNIQUE INDEX IF NOT EXISTS ux_accounts_platform_user_id
    ON accounts (platform_id, platform_user_id)
    WHERE platform_user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_accounts_platform_id
    ON accounts (platform_id);

CREATE TABLE IF NOT EXISTS account_username_history (
    username_history_id INTEGER PRIMARY KEY,
    account_id INTEGER NOT NULL,
    platform_id INTEGER NOT NULL,
    username TEXT COLLATE NOCASE NOT NULL,
    first_observed_at TEXT NOT NULL,
    last_observed_at TEXT NOT NULL,
    valid_from TEXT NOT NULL,
    valid_to TEXT,
    evidence_source TEXT NOT NULL,
    FOREIGN KEY (account_id, platform_id)
        REFERENCES accounts (account_id, platform_id)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    UNIQUE (account_id, username, first_observed_at),
    CHECK (length(trim(username)) > 0),
    CHECK (length(trim(first_observed_at)) > 0),
    CHECK (length(trim(last_observed_at)) > 0),
    CHECK (length(trim(valid_from)) > 0),
    CHECK (length(trim(evidence_source)) > 0),
    CHECK (last_observed_at >= first_observed_at),
    CHECK (valid_to IS NULL OR valid_to > valid_from)
);

-- Only one current username may belong to an account.
CREATE UNIQUE INDEX IF NOT EXISTS ux_username_one_current_per_account
    ON account_username_history (account_id)
    WHERE valid_to IS NULL;

-- A current username may belong to only one account on a platform.
CREATE UNIQUE INDEX IF NOT EXISTS ux_username_current_per_platform
    ON account_username_history (platform_id, username)
    WHERE valid_to IS NULL;

CREATE INDEX IF NOT EXISTS ix_username_history_lookup
    ON account_username_history (platform_id, username, valid_from);

CREATE INDEX IF NOT EXISTS ix_username_history_account
    ON account_username_history (account_id, valid_from);

CREATE TABLE IF NOT EXISTS posts (
    post_id INTEGER PRIMARY KEY,
    platform_id INTEGER NOT NULL,
    author_account_id INTEGER NOT NULL,
    platform_post_id TEXT,
    content TEXT NOT NULL,
    published_at TEXT NOT NULL,
    ingested_at TEXT NOT NULL,
    UNIQUE (post_id, platform_id),
    FOREIGN KEY (author_account_id, platform_id)
        REFERENCES accounts (account_id, platform_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CHECK (platform_post_id IS NULL OR length(trim(platform_post_id)) > 0),
    CHECK (length(trim(content)) > 0),
    CHECK (length(trim(published_at)) > 0),
    CHECK (length(trim(ingested_at)) > 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_posts_platform_post_id
    ON posts (platform_id, platform_post_id)
    WHERE platform_post_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_posts_author_published
    ON posts (author_account_id, published_at);

CREATE INDEX IF NOT EXISTS ix_posts_published_at
    ON posts (published_at);

CREATE TABLE IF NOT EXISTS interactions (
    interaction_id INTEGER PRIMARY KEY,
    platform_id INTEGER NOT NULL,
    actor_account_id INTEGER NOT NULL,
    target_post_id INTEGER NOT NULL,
    interaction_type TEXT NOT NULL,
    platform_interaction_id TEXT,
    interacted_at TEXT NOT NULL,
    ingested_at TEXT NOT NULL,
    FOREIGN KEY (actor_account_id, platform_id)
        REFERENCES accounts (account_id, platform_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    FOREIGN KEY (target_post_id, platform_id)
        REFERENCES posts (post_id, platform_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CHECK (interaction_type IN ('Like', 'Reply', 'Repost', 'Quote')),
    CHECK (
        platform_interaction_id IS NULL
        OR length(trim(platform_interaction_id)) > 0
    ),
    CHECK (length(trim(interacted_at)) > 0),
    CHECK (length(trim(ingested_at)) > 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_interactions_platform_event_id
    ON interactions (platform_id, platform_interaction_id)
    WHERE platform_interaction_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_interactions_actor_time
    ON interactions (actor_account_id, interacted_at);

CREATE INDEX IF NOT EXISTS ix_interactions_target_type
    ON interactions (target_post_id, interaction_type);

CREATE INDEX IF NOT EXISTS ix_interactions_platform_type
    ON interactions (platform_id, interaction_type);
