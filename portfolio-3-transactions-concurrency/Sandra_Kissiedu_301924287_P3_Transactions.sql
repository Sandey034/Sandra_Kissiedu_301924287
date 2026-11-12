-- Raise the score of active session 2 (rule 5), on an open board (rule 6).
BEGIN;

UPDATE public.game_session
SET score = 1800,
    score_updated_at = TIMESTAMPTZ '2026-03-02 10:45:00+00'
WHERE session_id = 2
  AND ended_at IS NULL
  AND score = 900
  AND leaderboard_id IN (SELECT leaderboard_id
                         FROM public.leaderboard
                         WHERE status = 'open');

COMMIT;

-- Start a transaction and make one valid change to active session 3.
BEGIN;

UPDATE public.game_session
SET score = 400,
    score_updated_at = TIMESTAMPTZ '2026-03-02 11:30:00+00'
WHERE session_id = 3
  AND ended_at IS NULL
  AND score = 0;

  -- Deliberate violation of ck_game_session_score (score >= 0).
UPDATE public.game_session
SET score = -50
WHERE session_id = 2;

-- Undo everything since BEGIN, including the valid change to session 3.
ROLLBACK;

-- The committed change should remain; the rolled-back change should be gone.
SELECT session_id, score, score_updated_at
FROM public.game_session
WHERE session_id IN (2, 3)
ORDER BY session_id;