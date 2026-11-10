-- SampleData.sql: small valid dataset (fictional)
-- Run once, after the schema. Running it twice fails on the unique usernames.
-- Rows are inserted parent first. IDs are looked up, never typed.

BEGIN;

-- 4 players. dev_demo will have no sessions or achievements.
INSERT INTO public.player (username, registered_at) VALUES
    ('ana_demo',  TIMESTAMPTZ '2026-01-05 09:00:00+00'),
    ('ben_demo',  TIMESTAMPTZ '2026-01-06 09:00:00+00'),
    ('cara_demo', TIMESTAMPTZ '2026-01-07 09:00:00+00'),
    ('dev_demo',  TIMESTAMPTZ '2026-01-08 09:00:00+00');

-- 3 leaderboards: two open, one closed
INSERT INTO public.leaderboard (name, status) VALUES
    ('Spring Open Board',  'open'),
    ('Summer Open Board',  'open'),
    ('Winter Closed Board', 'closed');

-- 2 achievements: one with a description, one without (optional field)
INSERT INTO public.achievement (code, title, description) VALUES
    ('FIRST_WIN',  'First Win',  'Win your first game.'),
    ('SCORE_1000', 'Score 1000', NULL);

-- 6 sessions (player and leaderboard IDs found by unique username / name)
-- Row 1: ended session. Row 2: active session (ended_at is NULL).
-- Row 3: active session on another board, score uses the default (0).
-- Rows 4-5: Ben and Cara tie on score and time (for the rule 7 tie-break).
-- Row 6: ended session on the closed board.
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'ana_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Spring Open Board'),
     TIMESTAMPTZ '2026-03-01 10:00:00+00', TIMESTAMPTZ '2026-03-01 10:30:00+00',
     1500, TIMESTAMPTZ '2026-03-01 10:25:00+00'),

    ((SELECT player_id FROM public.player WHERE username = 'ana_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Spring Open Board'),
     TIMESTAMPTZ '2026-03-02 10:00:00+00', NULL,
     900, TIMESTAMPTZ '2026-03-02 10:20:00+00'),

    ((SELECT player_id FROM public.player WHERE username = 'ana_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     TIMESTAMPTZ '2026-03-02 11:00:00+00', NULL,
     DEFAULT, TIMESTAMPTZ '2026-03-02 11:00:00+00'),

    ((SELECT player_id FROM public.player WHERE username = 'ben_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Spring Open Board'),
     TIMESTAMPTZ '2026-03-01 12:00:00+00', TIMESTAMPTZ '2026-03-01 12:40:00+00',
     1200, TIMESTAMPTZ '2026-03-01 12:30:00+00'),

    ((SELECT player_id FROM public.player WHERE username = 'cara_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Spring Open Board'),
     TIMESTAMPTZ '2026-03-01 12:10:00+00', TIMESTAMPTZ '2026-03-01 12:45:00+00',
     1200, TIMESTAMPTZ '2026-03-01 12:30:00+00'),

    ((SELECT player_id FROM public.player WHERE username = 'ben_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Winter Closed Board'),
     TIMESTAMPTZ '2026-01-20 15:00:00+00', TIMESTAMPTZ '2026-01-20 15:30:00+00',
     700, TIMESTAMPTZ '2026-01-20 15:20:00+00');

-- 3 awards (awarded_at is after the player's registered_at)
INSERT INTO public.player_achievement (player_id, achievement_id, awarded_at) VALUES
    ((SELECT player_id FROM public.player WHERE username = 'ana_demo'),
     (SELECT achievement_id FROM public.achievement WHERE code = 'FIRST_WIN'),
     TIMESTAMPTZ '2026-03-01 10:31:00+00'),
    ((SELECT player_id FROM public.player WHERE username = 'ana_demo'),
     (SELECT achievement_id FROM public.achievement WHERE code = 'SCORE_1000'),
     TIMESTAMPTZ '2026-03-01 10:32:00+00'),
    ((SELECT player_id FROM public.player WHERE username = 'ben_demo'),
     (SELECT achievement_id FROM public.achievement WHERE code = 'FIRST_WIN'),
     TIMESTAMPTZ '2026-03-01 12:41:00+00');

COMMIT;

