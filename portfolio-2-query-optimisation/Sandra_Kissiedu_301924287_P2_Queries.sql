Query 1: Ranking for Spring Open Board (rule 7)
-- Each player's best score on one leaderboard, ranked.
-- Ties: earlier score_updated_at first, then lower player_id.
WITH best AS (
    SELECT DISTINCT ON (gs.player_id)
           gs.player_id, gs.score, gs.score_updated_at
    FROM public.game_session gs
    JOIN public.leaderboard l ON l.leaderboard_id = gs.leaderboard_id
    WHERE l.name = 'Spring Open Board'
    ORDER BY gs.player_id, gs.score DESC, gs.score_updated_at ASC
)
SELECT ROW_NUMBER() OVER (
           ORDER BY b.score DESC, b.score_updated_at ASC, b.player_id ASC
       ) AS position,
       p.username,
       b.score,
       b.score_updated_at
FROM best b
JOIN public.player p ON p.player_id = b.player_id
ORDER BY position;

Query 2: Players with no game sessions
-- Players who have never played a session.
SELECT p.player_id, p.username, p.registered_at
FROM public.player p
WHERE NOT EXISTS (
    SELECT 1
    FROM public.game_session gs
    WHERE gs.player_id = p.player_id
)
ORDER BY p.player_id;

Query 3: Achievements earned per player (zero counts kept)
-- Count of achievements per player. LEFT JOIN keeps players with none.
SELECT p.username,
       COUNT(pa.achievement_id) AS achievements_earned
FROM public.player p
LEFT JOIN public.player_achievement pa ON pa.player_id = p.player_id
GROUP BY p.player_id, p.username
ORDER BY achievements_earned DESC, p.username;