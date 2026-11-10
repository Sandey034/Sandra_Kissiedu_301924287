-- ConstraintTests.sql: deliberately invalid inserts
-- Run AFTER SampleData.sql. Do NOT use BEGIN/COMMIT here, so one error
-- does not block the next test. In psql, \i keeps going after errors
-- unless you set ON_ERROR_STOP.
-- Every statement below should fail, so no rows are added.
-- Rules 5, 6 and 8 (ended sessions, open boards, awarded_at dates) are not
-- enforced by these tables, so they are not tested here.

-- ===== player =====

-- Test 1: missing username
-- Expected: null value in column "username" of relation "player" violates not-null constraint
INSERT INTO public.player (username, registered_at)
VALUES (NULL, TIMESTAMPTZ '2026-02-01 09:00:00+00');

-- Test 2: missing registered_at
-- Expected: null value in column "registered_at" of relation "player" violates not-null constraint
INSERT INTO public.player (username, registered_at)
VALUES ('eve_demo', NULL);

-- Test 3: duplicate username
-- Expected: duplicate key value violates unique constraint "uq_player_username"
INSERT INTO public.player (username, registered_at)
VALUES ('ana_demo', TIMESTAMPTZ '2026-02-01 09:00:00+00');

-- Test 4: username longer than 30 characters (31 here)
-- Expected: value too long for type character varying(30)
INSERT INTO public.player (username, registered_at)
VALUES ('abcdefghijklmnopqrstuvwxyz12345', TIMESTAMPTZ '2026-02-01 09:00:00+00');

-- Test 5: typing an ID by hand (IDs are GENERATED ALWAYS)
-- Expected: cannot insert a non-DEFAULT value into column "player_id"
INSERT INTO public.player (player_id, username, registered_at)
VALUES (500, 'fay_demo', TIMESTAMPTZ '2026-02-01 09:00:00+00');

-- ===== leaderboard =====

-- Test 6: missing name
-- Expected: null value in column "name" of relation "leaderboard" violates not-null constraint
INSERT INTO public.leaderboard (name, status)
VALUES (NULL, 'open');

-- Test 7: missing status
-- Expected: null value in column "status" of relation "leaderboard" violates not-null constraint
INSERT INTO public.leaderboard (name, status)
VALUES ('Autumn Board', NULL);

-- Test 8: status is not 'open' or 'closed'
-- Expected: new row for relation "leaderboard" violates check constraint "ck_leaderboard_status"
INSERT INTO public.leaderboard (name, status)
VALUES ('Autumn Board', 'paused');

-- ===== achievement =====

-- Test 9: missing code
-- Expected: null value in column "code" of relation "achievement" violates not-null constraint
INSERT INTO public.achievement (code, title, description)
VALUES (NULL, 'Veteran', 'Play 100 games.');

-- Test 10: missing title
-- Expected: null value in column "title" of relation "achievement" violates not-null constraint
INSERT INTO public.achievement (code, title, description)
VALUES ('VETERAN', NULL, 'Play 100 games.');

-- Test 11: duplicate code
-- Expected: duplicate key value violates unique constraint "uq_achievement_code"
INSERT INTO public.achievement (code, title, description)
VALUES ('FIRST_WIN', 'Another Title', 'Duplicate code.');

-- ===== game_session =====
-- Valid player: dev_demo (no sessions). Valid board: Summer Open Board.

-- Test 12: missing player_id
-- Expected: null value in column "player_id" of relation "game_session" violates not-null constraint
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    (NULL,
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', NULL, 0, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 13: missing leaderboard_id
-- Expected: null value in column "leaderboard_id" of relation "game_session" violates not-null constraint
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     NULL,
     TIMESTAMPTZ '2026-03-10 10:00:00+00', NULL, 0, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 14: missing started_at
-- Expected: null value in column "started_at" of relation "game_session" violates not-null constraint
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     NULL, NULL, 0, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 15: missing score (explicit NULL, not the default)
-- Expected: null value in column "score" of relation "game_session" violates not-null constraint
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', NULL, NULL, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 16: missing score_updated_at
-- Expected: null value in column "score_updated_at" of relation "game_session" violates not-null constraint
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', NULL, 0, NULL);

-- Test 17: player does not exist (largest existing ID + 1,000,000)
-- Expected: insert or update on table "game_session" violates foreign key constraint "fk_game_session_player"
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT COALESCE(MAX(player_id), 0) + 1000000 FROM public.player),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', NULL, 0, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 18: leaderboard does not exist
-- Expected: insert or update on table "game_session" violates foreign key constraint "fk_game_session_leaderboard"
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT COALESCE(MAX(leaderboard_id), 0) + 1000000 FROM public.leaderboard),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', NULL, 0, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 19: negative score
-- Expected: new row for relation "game_session" violates check constraint "ck_game_session_score"
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', NULL, -1, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 20: ended_at earlier than started_at
-- Expected: new row for relation "game_session" violates check constraint "ck_game_session_ended"
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', TIMESTAMPTZ '2026-03-10 09:00:00+00',
     0, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 21: ended_at equal to started_at (must be LATER)
-- Expected: new row for relation "game_session" violates check constraint "ck_game_session_ended"
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Summer Open Board'),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', TIMESTAMPTZ '2026-03-10 10:00:00+00',
     0, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 22: second ACTIVE session for the same player and board
-- (ana_demo already has an active session on Spring Open Board)
-- Expected: duplicate key value violates unique constraint "uq_game_session_active"
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'ana_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Spring Open Board'),
     TIMESTAMPTZ '2026-03-10 10:00:00+00', NULL, 0, TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- ===== player_achievement =====

-- Test 23: missing player_id
-- Expected: null value in column "player_id" of relation "player_achievement" violates not-null constraint
INSERT INTO public.player_achievement (player_id, achievement_id, awarded_at)
VALUES (NULL,
        (SELECT achievement_id FROM public.achievement WHERE code = 'FIRST_WIN'),
        TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 24: missing achievement_id
-- Expected: null value in column "achievement_id" of relation "player_achievement" violates not-null constraint
INSERT INTO public.player_achievement (player_id, achievement_id, awarded_at)
VALUES ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
        NULL,
        TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 25: missing awarded_at
-- Expected: null value in column "awarded_at" of relation "player_achievement" violates not-null constraint
INSERT INTO public.player_achievement (player_id, achievement_id, awarded_at)
VALUES ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
        (SELECT achievement_id FROM public.achievement WHERE code = 'FIRST_WIN'),
        NULL);

-- Test 26: same achievement awarded twice to the same player
-- Expected: duplicate key value violates unique constraint "pk_player_achievement"
INSERT INTO public.player_achievement (player_id, achievement_id, awarded_at)
VALUES ((SELECT player_id FROM public.player WHERE username = 'ana_demo'),
        (SELECT achievement_id FROM public.achievement WHERE code = 'FIRST_WIN'),
        TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 27: player does not exist
-- Expected: insert or update on table "player_achievement" violates foreign key constraint "fk_player_achievement_player"
INSERT INTO public.player_achievement (player_id, achievement_id, awarded_at)
VALUES ((SELECT COALESCE(MAX(player_id), 0) + 1000000 FROM public.player),
        (SELECT achievement_id FROM public.achievement WHERE code = 'FIRST_WIN'),
        TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- Test 28: achievement does not exist
-- Expected: insert or update on table "player_achievement" violates foreign key constraint "fk_player_achievement_achievement"
INSERT INTO public.player_achievement (player_id, achievement_id, awarded_at)
VALUES ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
        (SELECT COALESCE(MAX(achievement_id), 0) + 1000000 FROM public.achievement),
        TIMESTAMPTZ '2026-03-10 10:00:00+00');

-- ===== Final check =====
-- Expected counts (same as after SampleData.sql, because every test above failed):
-- player 4, leaderboard 3, achievement 2, game_session 6, player_achievement 3
SELECT 'player' AS table_name, COUNT(*) AS row_count FROM public.player
UNION ALL SELECT 'leaderboard',        COUNT(*) FROM public.leaderboard
UNION ALL SELECT 'achievement',        COUNT(*) FROM public.achievement
UNION ALL SELECT 'game_session',       COUNT(*) FROM public.game_session
UNION ALL SELECT 'player_achievement', COUNT(*) FROM public.player_achievement;