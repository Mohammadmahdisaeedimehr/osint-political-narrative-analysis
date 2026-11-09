-- Each query starts with a unique name. db.py loads these sections by name.

-- name: daily_post_counts
-- Count posts by UTC publication date.
SELECT
    substr(published_at, 1, 10) AS publication_date,
    COUNT(*) AS post_count
FROM posts
GROUP BY substr(published_at, 1, 10)
ORDER BY publication_date;

-- name: top_5_accounts_by_post_count
-- Include accounts with zero authored posts.
SELECT
    a.account_id,
    pl.platform_name,
    COALESCE(uh.username, '[no current username]') AS current_username,
    COUNT(p.post_id) AS post_count
FROM accounts AS a
JOIN platforms AS pl
    ON pl.platform_id = a.platform_id
LEFT JOIN account_username_history AS uh
    ON uh.account_id = a.account_id
   AND uh.valid_to IS NULL
LEFT JOIN posts AS p
    ON p.author_account_id = a.account_id
GROUP BY a.account_id, pl.platform_name, uh.username
ORDER BY post_count DESC, a.account_id
LIMIT 5;

-- name: posts_without_interactions
-- Find posts for which no interaction row exists.
SELECT
    p.post_id,
    pl.platform_name,
    COALESCE(uh.username, '[no current username]') AS author_username,
    p.content,
    p.published_at
FROM posts AS p
JOIN platforms AS pl
    ON pl.platform_id = p.platform_id
JOIN accounts AS a
    ON a.account_id = p.author_account_id
LEFT JOIN account_username_history AS uh
    ON uh.account_id = a.account_id
   AND uh.valid_to IS NULL
WHERE NOT EXISTS (
    SELECT 1
    FROM interactions AS i
    WHERE i.target_post_id = p.post_id
)
ORDER BY p.post_id;

-- name: interaction_type_distribution_by_platform
-- Count each interaction type on each platform.
SELECT
    pl.platform_name,
    i.interaction_type,
    COUNT(*) AS interaction_count
FROM interactions AS i
JOIN platforms AS pl
    ON pl.platform_id = i.platform_id
GROUP BY pl.platform_name, i.interaction_type
ORDER BY pl.platform_name, i.interaction_type;

-- name: top_5_posts_by_unique_interacting_accounts
-- Rank posts by distinct accounts that interacted with them.
SELECT
    p.post_id,
    pl.platform_name,
    COALESCE(uh.username, '[no current username]') AS author_username,
    substr(p.content, 1, 80) AS content_preview,
    COUNT(DISTINCT i.actor_account_id) AS unique_interacting_accounts
FROM posts AS p
JOIN platforms AS pl
    ON pl.platform_id = p.platform_id
JOIN accounts AS a
    ON a.account_id = p.author_account_id
LEFT JOIN account_username_history AS uh
    ON uh.account_id = a.account_id
   AND uh.valid_to IS NULL
LEFT JOIN interactions AS i
    ON i.target_post_id = p.post_id
GROUP BY p.post_id, pl.platform_name, uh.username, p.content
HAVING COUNT(DISTINCT i.actor_account_id) > 0
ORDER BY unique_interacting_accounts DESC, p.post_id
LIMIT 5;
