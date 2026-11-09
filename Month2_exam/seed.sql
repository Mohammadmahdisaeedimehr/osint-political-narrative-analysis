-- Synthetic demonstration data only. No real user data is included.
-- Explicit IDs and INSERT OR IGNORE make this seed script repeatable.

INSERT OR IGNORE INTO platforms (platform_id, platform_name, created_at) VALUES
    (1, 'X',         '2026-11-01T00:00:00Z'),
    (2, 'Telegram',  '2026-11-01T00:00:00Z'),
    (3, 'Instagram', '2026-11-01T00:00:00Z');

INSERT OR IGNORE INTO accounts
    (account_id, platform_id, platform_user_id, first_seen_at, last_seen_at, created_at)
VALUES
    (1,  1, 'x-1001',  '2026-01-01T00:00:00Z', '2026-11-05T10:00:00Z', '2026-01-01T00:00:00Z'),
    (2,  1, 'x-1002',  '2026-11-01T00:00:00Z', '2026-11-05T11:00:00Z', '2026-11-01T00:00:00Z'),
    (3,  1, 'x-1003',  '2026-11-01T00:00:00Z', '2026-11-04T09:00:00Z', '2026-11-01T00:00:00Z'),
    (4,  1, 'x-1004',  '2026-11-01T00:00:00Z', '2026-11-05T10:00:00Z', '2026-11-01T00:00:00Z'),
    (5,  1, 'x-1005',  '2026-11-01T00:00:00Z', '2026-11-05T10:00:00Z', '2026-11-01T00:00:00Z'),
    (6,  2, 'tg-2001', '2026-11-01T00:00:00Z', '2026-11-03T14:00:00Z', '2026-11-01T00:00:00Z'),
    (7,  2, 'tg-2002', '2026-11-01T00:00:00Z', '2026-11-04T15:00:00Z', '2026-11-01T00:00:00Z'),
    (8,  2, 'tg-2003', '2026-11-01T00:00:00Z', '2026-11-05T16:00:00Z', '2026-11-01T00:00:00Z'),
    (9,  3, 'ig-3001', '2026-11-01T00:00:00Z', '2026-11-05T07:00:00Z', '2026-11-01T00:00:00Z'),
    (10, 3, 'ig-3002', '2026-11-01T00:00:00Z', '2026-11-05T08:00:00Z', '2026-11-01T00:00:00Z');

INSERT OR IGNORE INTO account_username_history
    (username_history_id, account_id, platform_id, username,
     first_observed_at, last_observed_at, valid_from, valid_to, evidence_source)
VALUES
    (1,  1, 1, '@ali_old', '2026-01-01T00:00:00Z', '2026-03-09T00:00:00Z',
     '2026-01-01T00:00:00Z', '2026-03-10T00:00:00Z', 'verified_profile_history'),
    (2,  1, 1, '@ali', '2026-03-10T00:00:00Z', '2026-11-05T10:00:00Z',
     '2026-03-10T00:00:00Z', NULL, 'platform_user_id'),
    (3,  2, 1, '@sara', '2026-11-01T00:00:00Z', '2026-11-05T11:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id'),
    (4,  3, 1, '@reza', '2026-11-01T00:00:00Z', '2026-11-04T09:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id'),
    (5,  4, 1, '@mina', '2026-11-01T00:00:00Z', '2026-11-05T10:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id'),
    (6,  5, 1, '@x_reader', '2026-11-01T00:00:00Z', '2026-11-05T10:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id'),
    (7,  6, 2, '@navid', '2026-11-01T00:00:00Z', '2026-11-03T14:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id'),
    (8,  7, 2, '@leila', '2026-11-01T00:00:00Z', '2026-11-04T15:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id'),
    (9,  8, 2, '@omid', '2026-11-01T00:00:00Z', '2026-11-05T16:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id'),
    (10, 9, 3, '@nima', '2026-11-01T00:00:00Z', '2026-11-05T07:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id'),
    (11, 10, 3, '@arya', '2026-11-01T00:00:00Z', '2026-11-05T08:00:00Z',
     '2026-11-01T00:00:00Z', NULL, 'platform_user_id');

INSERT OR IGNORE INTO posts
    (post_id, platform_id, author_account_id, platform_post_id, content, published_at, ingested_at)
VALUES
    (1,  1, 1,  'x-post-001',  'A short update about public transport policy.',       '2026-11-01T09:00:00Z', '2026-11-01T09:02:00Z'),
    (2,  1, 2,  'x-post-002',  'A discussion about regional economic indicators.',   '2026-11-01T10:00:00Z', '2026-11-01T10:01:00Z'),
    (3,  1, 3,  'x-post-003',  'A question about a new education proposal.',         '2026-11-02T08:00:00Z', '2026-11-02T08:03:00Z'),
    (4,  1, 4,  'x-post-004',  'A note about urban development priorities.',         '2026-11-02T10:00:00Z', '2026-11-02T10:02:00Z'),
    (5,  1, 1,  'x-post-005',  'A summary of a public budget announcement.',         '2026-11-03T09:00:00Z', '2026-11-03T09:02:00Z'),
    (6,  1, 2,  'x-post-006',  'An observation about energy market trends.',         '2026-11-03T11:00:00Z', '2026-11-03T11:01:00Z'),
    (7,  1, 3,  'x-post-007',  'A thread about digital public services.',             '2026-11-04T09:00:00Z', '2026-11-04T09:02:00Z'),
    (8,  1, 4,  'x-post-008',  'A short note about local community activities.',     '2026-11-05T10:00:00Z', '2026-11-05T10:01:00Z'),
    (9,  2, 6,  'tg-post-009', 'A channel post about science communication.',        '2026-11-01T08:00:00Z', '2026-11-01T08:02:00Z'),
    (10, 2, 7,  'tg-post-010', 'A message about a new research publication.',        '2026-11-01T12:00:00Z', '2026-11-01T12:02:00Z'),
    (11, 2, 8,  'tg-post-011', 'A public note about cultural events.',                '2026-11-02T13:00:00Z', '2026-11-02T13:01:00Z'),
    (12, 2, 6,  'tg-post-012', 'A summary of a technology policy discussion.',       '2026-11-03T14:00:00Z', '2026-11-03T14:02:00Z'),
    (13, 2, 7,  'tg-post-013', 'A post about a university seminar.',                 '2026-11-04T15:00:00Z', '2026-11-04T15:01:00Z'),
    (14, 2, 8,  'tg-post-014', 'A note about a community reading group.',            '2026-11-05T16:00:00Z', '2026-11-05T16:01:00Z'),
    (15, 3, 9,  'ig-post-015', 'A photo caption about a museum visit.',              '2026-11-01T07:00:00Z', '2026-11-01T07:02:00Z'),
    (16, 3, 10, 'ig-post-016', 'A short caption about a local food market.',         '2026-11-02T07:00:00Z', '2026-11-02T07:02:00Z'),
    (17, 3, 9,  'ig-post-017', 'A caption about a public art exhibition.',           '2026-11-03T07:00:00Z', '2026-11-03T07:02:00Z'),
    (18, 3, 10, 'ig-post-018', 'A photo caption about a city park.',                 '2026-11-04T07:00:00Z', '2026-11-04T07:02:00Z'),
    (19, 3, 9,  'ig-post-019', 'A caption about a volunteer event.',                 '2026-11-05T07:00:00Z', '2026-11-05T07:02:00Z'),
    (20, 3, 10, 'ig-post-020', 'A note about a weekend photography walk.',            '2026-11-05T08:00:00Z', '2026-11-05T08:02:00Z');

INSERT OR IGNORE INTO interactions
    (interaction_id, platform_id, actor_account_id, target_post_id,
     interaction_type, platform_interaction_id, interacted_at, ingested_at)
VALUES
    (1,  1, 2, 1, 'Like',   'x-int-001', '2026-11-01T09:10:00Z', '2026-11-01T09:11:00Z'),
    (2,  1, 3, 1, 'Reply',  'x-int-002', '2026-11-01T09:12:00Z', '2026-11-01T09:13:00Z'),
    (3,  1, 4, 1, 'Repost', 'x-int-003', '2026-11-01T09:14:00Z', '2026-11-01T09:15:00Z'),
    (4,  1, 5, 1, 'Like',   'x-int-004', '2026-11-01T09:16:00Z', '2026-11-01T09:17:00Z'),
    (5,  1, 1, 2, 'Like',   'x-int-005', '2026-11-01T10:10:00Z', '2026-11-01T10:11:00Z'),
    (6,  1, 3, 2, 'Like',   'x-int-006', '2026-11-01T10:12:00Z', '2026-11-01T10:13:00Z'),
    (7,  1, 4, 2, 'Quote',  'x-int-007', '2026-11-01T10:14:00Z', '2026-11-01T10:15:00Z'),
    (8,  1, 1, 3, 'Reply',  'x-int-008', '2026-11-02T08:10:00Z', '2026-11-02T08:11:00Z'),
    (9,  1, 2, 3, 'Like',   'x-int-009', '2026-11-02T08:12:00Z', '2026-11-02T08:13:00Z'),
    (10, 1, 5, 3, 'Like',   'x-int-010', '2026-11-02T08:14:00Z', '2026-11-02T08:15:00Z'),
    (11, 1, 1, 4, 'Like',   'x-int-011', '2026-11-02T10:10:00Z', '2026-11-02T10:11:00Z'),
    (12, 1, 2, 4, 'Repost', 'x-int-012', '2026-11-02T10:12:00Z', '2026-11-02T10:13:00Z'),
    (13, 1, 5, 4, 'Reply',  'x-int-013', '2026-11-02T10:14:00Z', '2026-11-02T10:15:00Z'),
    (14, 1, 2, 5, 'Like',   'x-int-014', '2026-11-03T09:10:00Z', '2026-11-03T09:11:00Z'),
    (15, 1, 3, 5, 'Like',   'x-int-015', '2026-11-03T09:12:00Z', '2026-11-03T09:13:00Z'),
    (16, 1, 4, 5, 'Quote',  'x-int-016', '2026-11-03T09:14:00Z', '2026-11-03T09:15:00Z'),
    (17, 1, 1, 6, 'Repost', 'x-int-017', '2026-11-03T11:10:00Z', '2026-11-03T11:11:00Z'),
    (18, 1, 4, 6, 'Like',   'x-int-018', '2026-11-03T11:12:00Z', '2026-11-03T11:13:00Z'),
    (19, 1, 2, 7, 'Reply',  'x-int-019', '2026-11-04T09:10:00Z', '2026-11-04T09:11:00Z'),
    (20, 1, 5, 7, 'Like',   'x-int-020', '2026-11-04T09:12:00Z', '2026-11-04T09:13:00Z'),
    (21, 2, 7, 9, 'Like',   'tg-int-021', '2026-11-01T08:10:00Z', '2026-11-01T08:11:00Z'),
    (22, 2, 8, 9, 'Reply',  'tg-int-022', '2026-11-01T08:12:00Z', '2026-11-01T08:13:00Z'),
    (23, 2, 6, 10, 'Like',  'tg-int-023', '2026-11-01T12:10:00Z', '2026-11-01T12:11:00Z'),
    (24, 2, 8, 10, 'Repost','tg-int-024', '2026-11-01T12:12:00Z', '2026-11-01T12:13:00Z'),
    (25, 2, 6, 11, 'Like',  'tg-int-025', '2026-11-02T13:10:00Z', '2026-11-02T13:11:00Z'),
    (26, 2, 7, 11, 'Quote', 'tg-int-026', '2026-11-02T13:12:00Z', '2026-11-02T13:13:00Z'),
    (27, 2, 7, 12, 'Like',  'tg-int-027', '2026-11-03T14:10:00Z', '2026-11-03T14:11:00Z'),
    (28, 2, 8, 12, 'Reply', 'tg-int-028', '2026-11-03T14:12:00Z', '2026-11-03T14:13:00Z'),
    (29, 2, 6, 13, 'Repost','tg-int-029', '2026-11-04T15:10:00Z', '2026-11-04T15:11:00Z'),
    (30, 2, 8, 13, 'Like',  'tg-int-030', '2026-11-04T15:12:00Z', '2026-11-04T15:13:00Z'),
    (31, 3, 10, 15, 'Like',  'ig-int-031', '2026-11-01T07:10:00Z', '2026-11-01T07:11:00Z'),
    (32, 3, 9, 16, 'Like',   'ig-int-032', '2026-11-02T07:10:00Z', '2026-11-02T07:11:00Z'),
    (33, 3, 10, 17, 'Reply', 'ig-int-033', '2026-11-03T07:10:00Z', '2026-11-03T07:11:00Z'),
    (34, 3, 9, 17, 'Repost', 'ig-int-034', '2026-11-03T07:12:00Z', '2026-11-03T07:13:00Z'),
    (35, 3, 9, 18, 'Quote',  'ig-int-035', '2026-11-04T07:10:00Z', '2026-11-04T07:11:00Z'),
    (36, 3, 10, 19, 'Like',  'ig-int-036', '2026-11-05T07:10:00Z', '2026-11-05T07:11:00Z');
