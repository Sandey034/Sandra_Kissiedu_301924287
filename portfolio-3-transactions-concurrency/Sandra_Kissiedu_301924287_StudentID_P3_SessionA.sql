-- Session A, step 1: explicit isolation level, then insert but do NOT commit.
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;

INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Spring Open Board'),
     TIMESTAMPTZ '2026-03-10 09:00:00+00', NULL,
     0, TIMESTAMPTZ '2026-03-10 09:00:00+00');

-- Switch to Session B. Do not commit A yet.

--Committing makes A’s session permanent and lets PostgreSQL decide B’s insert.
-- Session A, step 3: commit, which releases B.
COMMIT;

--Switch to Session B.