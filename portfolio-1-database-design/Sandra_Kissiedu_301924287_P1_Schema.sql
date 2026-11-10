-- MIT 8103 Portfolio 1: Real-time Game Leaderboard (PostgreSQL 16)
-- Run after: \c game_leaderboard_portfolio

BEGIN;

-- Registered players (rule 1)
CREATE TABLE public.player (
    player_id     BIGINT GENERATED ALWAYS AS IDENTITY,
    username      VARCHAR(30) NOT NULL,
    registered_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT pk_player PRIMARY KEY (player_id),
    CONSTRAINT uq_player_username UNIQUE (username)
);

-- Ranking boards, open or closed (rule 2)
CREATE TABLE public.leaderboard (
    leaderboard_id BIGINT GENERATED ALWAYS AS IDENTITY,
    name           VARCHAR(100) NOT NULL,
    status         VARCHAR(6) NOT NULL,
    CONSTRAINT pk_leaderboard PRIMARY KEY (leaderboard_id),
    CONSTRAINT ck_leaderboard_status CHECK (status IN ('open', 'closed'))
);

-- Defined achievements (rule 8: unique code)
CREATE TABLE public.achievement (
    achievement_id BIGINT GENERATED ALWAYS AS IDENTITY,
    code           VARCHAR(30) NOT NULL,
    title          VARCHAR(100) NOT NULL,
    description    VARCHAR(300),
    CONSTRAINT pk_achievement PRIMARY KEY (achievement_id),
    CONSTRAINT uq_achievement_code UNIQUE (code)
);

-- One play of a leaderboard by a player (rules 3, 5, 6)
CREATE TABLE public.game_session (
    session_id       BIGINT GENERATED ALWAYS AS IDENTITY,
    player_id        BIGINT NOT NULL,
    leaderboard_id   BIGINT NOT NULL,
    started_at       TIMESTAMPTZ NOT NULL,
    ended_at         TIMESTAMPTZ,
    score            INTEGER NOT NULL DEFAULT 0,
    score_updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT pk_game_session PRIMARY KEY (session_id),
    CONSTRAINT fk_game_session_player
        FOREIGN KEY (player_id) REFERENCES public.player (player_id),
    CONSTRAINT fk_game_session_leaderboard
        FOREIGN KEY (leaderboard_id) REFERENCES public.leaderboard (leaderboard_id),
    CONSTRAINT ck_game_session_score CHECK (score >= 0),
    CONSTRAINT ck_game_session_ended CHECK (ended_at IS NULL OR ended_at > started_at)
);

-- Rule 4: one active session per player per leaderboard
CREATE UNIQUE INDEX uq_game_session_active
    ON public.game_session (player_id, leaderboard_id)
    WHERE ended_at IS NULL;

-- Achievements awarded to players (rule 8: each earned once)
CREATE TABLE public.player_achievement (
    player_id      BIGINT NOT NULL,
    achievement_id BIGINT NOT NULL,
    awarded_at     TIMESTAMPTZ NOT NULL,
    CONSTRAINT pk_player_achievement PRIMARY KEY (player_id, achievement_id),
    CONSTRAINT fk_player_achievement_player
        FOREIGN KEY (player_id) REFERENCES public.player (player_id),
    CONSTRAINT fk_player_achievement_achievement
        FOREIGN KEY (achievement_id) REFERENCES public.achievement (achievement_id)
);

-- Limits: these tables do not enforce the rules below. They need
-- transaction logic or a trigger:
--   Rule 5: score updates only change rows where ended_at IS NULL.
--   Rule 6: new sessions and score updates only on open leaderboards.
--   Rule 7: rankings come from a query (highest score per player,
--           then score_updated_at ascending, then lower player_id).
--   Rule 8: awarded_at must not be earlier than the player's registered_at.

COMMIT;