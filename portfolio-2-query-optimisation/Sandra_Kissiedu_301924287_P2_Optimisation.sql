
-- Block 1: create a separate schema and one synthetic history table.
-- Run this block ONCE. It only creates new objects in p2_benchmark.

CREATE SCHEMA p2_benchmark;

-- SYNTHETIC table: made-up score history, not real Portfolio 1 data.
CREATE TABLE p2_benchmark.score_history (
    history_id     BIGINT GENERATED ALWAYS AS IDENTITY,
    session_id     BIGINT NOT NULL,
    player_id      BIGINT NOT NULL,
    leaderboard_id BIGINT NOT NULL,
    score_after    INTEGER NOT NULL,
    recorded_at    TIMESTAMPTZ NOT NULL,
    CONSTRAINT pk_score_history PRIMARY KEY (history_id),
    CONSTRAINT fk_score_history_session
        FOREIGN KEY (session_id) REFERENCES public.game_session (session_id),
    CONSTRAINT ck_score_history_score CHECK (score_after >= 0)
FROM generate_series(1, 100000) AS g(n)
JOIN (
    SELECT session_id, player_id, leaderboard_id,
           ROW_NUMBER() OVER (ORDER BY session_id) AS rn
    FROM public.game_session
) s ON s.rn = 1 + (g.n % 6)
ORDER BY g.n;



-- Block 3: update planner statistics, then count the rows.
ANALYZE p2_benchmark.score_history;

SELECT COUNT(*) AS total_rows FROM p2_benchmark.score_history;

-- Block 4: selective query, about 60 rows out of 100,000 (one hour on 10 April 2026).
-- The only index on this table is the primary key on history_id.
EXPLAIN (ANALYZE, BUFFERS)
SELECT history_id, session_id, score_after, recorded_at
FROM p2_benchmark.score_history
WHERE recorded_at >= TIMESTAMPTZ '2026-04-10 00:00:00+00'
  AND recorded_at <  TIMESTAMPTZ '2026-04-10 01:00:00+00'
ORDER BY recorded_at;

-- Block 4: selective query, about 60 rows out of 100,000 (one hour on 10 April 2026).
-- The only index on this table is the primary key on history_id.
-- Run once as a warm-up, then three times for measurement.
-- Ignore the first warm-up time; record the next three Execution Time values.
EXPLAIN (ANALYZE, BUFFERS)
SELECT history_id, session_id, score_after, recorded_at
FROM p2_benchmark.score_history
WHERE recorded_at >= TIMESTAMPTZ '2026-04-10 00:00:00+00'
  AND recorded_at <  TIMESTAMPTZ '2026-04-10 01:00:00+00'
ORDER BY recorded_at;

-- Block 5: one B-tree index on the column used in the date-range filter.
CREATE INDEX idx_score_history_recorded_at
    ON p2_benchmark.score_history (recorded_at);

-- Block 6: IDENTICAL query to Block 4, run after the index exists.
-- Run once as a warm-up, then three times for measurement.
-- Ignore the first warm-up time; record the next three Execution Time values.
EXPLAIN (ANALYZE, BUFFERS)
SELECT history_id, session_id, score_after, recorded_at
FROM p2_benchmark.score_history
WHERE recorded_at >= TIMESTAMPTZ '2026-04-10 00:00:00+00'
  AND recorded_at <  TIMESTAMPTZ '2026-04-10 01:00:00+00'
ORDER BY recorded_at;
