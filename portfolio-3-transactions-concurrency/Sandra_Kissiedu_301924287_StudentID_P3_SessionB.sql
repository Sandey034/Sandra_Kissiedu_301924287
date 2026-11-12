-- Session B, step 2a: same isolation level, then look for dev_demo's active session.
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;

SELECT COUNT(*) AS active_seen_by_b
FROM public.game_session gs
JOIN public.player p      ON p.player_id = gs.player_id
JOIN public.leaderboard l ON l.leaderboard_id = gs.leaderboard_id
WHERE p.username = 'dev_demo'
  AND l.name = 'Spring Open Board'
  AND gs.ended_at IS NULL;

--B cannot see A’s uncommitted row, because PostgreSQL never shows uncommitted data to other sessions.  

-- Session B, step 2b: try to start the conflicting active session.
INSERT INTO public.game_session
    (player_id, leaderboard_id, started_at, ended_at, score, score_updated_at)
VALUES
    ((SELECT player_id FROM public.player WHERE username = 'dev_demo'),
     (SELECT leaderboard_id FROM public.leaderboard WHERE name = 'Spring Open Board'),
     TIMESTAMPTZ '2026-03-10 09:00:05+00', NULL,
     0, TIMESTAMPTZ '2026-03-10 09:00:05+00');

--STOP.(B waiting). It should show B’s 0 count and the cursor hanging after the INSERT. Don’t press anything in B.

--Session B sees the error and rolls back
-- Session B, step 4: undo B's aborted transaction.
ROLLBACK;

--Final check.This proves rule 4 held, because only A’s session exists.

-- Step 5: exactly one active session should exist for dev_demo on Spring Open Board.
SELECT gs.session_id, p.username, l.name AS leaderboard,
       gs.started_at, gs.ended_at, gs.score
FROM public.game_session gs
JOIN public.player p      ON p.player_id = gs.player_id
JOIN public.leaderboard l ON l.leaderboard_id = gs.leaderboard_id
WHERE p.username = 'dev_demo'
  AND l.name = 'Spring Open Board'
ORDER BY gs.session_id;