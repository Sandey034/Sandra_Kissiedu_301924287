Real-time Game Leaderboard Database Design
1. Entities

I chose five entities.

| Entity | Information stored |
|---|---|
| player | A registered player |
| leaderboard | A ranking board that is open or closed |
| game_session | One play of a leaderboard by a player, with its current score |
| achievement | A defined achievement |
| player_achievement | One achievement awarded to one player (linking table) |

Rankings are not an entity. They are calculated from sessions, so a stored ranking table could become out of date. A linking table is needed because many players can earn many achievements.

2. Attributes and keys

Unique means no repeated values. Required means the value cannot be NULL (missing). IDs are generated automatically.

| Entity | Attributes and PostgreSQL types | Keys and required values |
|---|---|---|
| player | player_id BIGINT; username VARCHAR(30); registered_at TIMESTAMPTZ | PK: player_id. Unique: username. All required. |
| leaderboard | leaderboard_id BIGINT; name VARCHAR(100); status VARCHAR(6) | PK: leaderboard_id. All required. |
| game_session | session_id BIGINT; player_id BIGINT; leaderboard_id BIGINT; started_at TIMESTAMPTZ; ended_at TIMESTAMPTZ; score INTEGER; score_updated_at TIMESTAMPTZ | PK: session_id. FKs: player_id → player; leaderboard_id → leaderboard. All required except ended_at. |
| achievement | achievement_id BIGINT; code VARCHAR(30); title VARCHAR(100); description VARCHAR(300) | PK: achievement_id. Unique: code. All required except description. |
| player_achievement | player_id BIGINT; achievement_id BIGINT; awarded_at TIMESTAMPTZ | PK: (player_id, achievement_id). FKs to player and achievement. All required. |

ended_at stays empty while a session is active. Status holds “open” or “closed”. Score starts at 0.

Necessary additions (rules unchanged): registered_at is needed for rule 8. score_updated_at records when the current score was set, so rule 7 can rank earlier scores first.

3. Relationships

| Tables linked | Relationship | Meaning |
|---|---|---|
| player → game_session | One to many | A player has zero or more sessions. Each session belongs to exactly one player. |
| leaderboard → game_session | One to many | A leaderboard has zero or more sessions. Each session belongs to exactly one leaderboard. |
| player ↔ achievement | Many to many, through player_achievement | A player has zero or more achievements. An achievement is earned by zero or more players. Each link row refers to exactly one player and one achievement. |

For example, Ana can have sessions on Board A and Board B. Her best score on each board gives her one ranking entry per board.

## 4. Business rules and constraints

| Rule | Database check or operation |
|---|---|
| 1 | player_id is the PK, and username is unique. |
| 2 | leaderboard_id is the PK. A check allows status to be only “open” or “closed”. |
| 3 | Required foreign keys link each session to an existing player and leaderboard. |
| 4 | A unique index on (player_id, leaderboard_id) applies only where ended_at is missing. Ana can have an active session on Board A and another on Board B, but not two on Board A. |
| 5 | A check requires score >= 0, and INTEGER holds whole numbers. A key cannot stop updates to ended sessions, so the score update operation changes only rows where ended_at is missing. |
| 6 | A check requires ended_at to be later than started_at. A key cannot see another table, so session creation and score updates check in one transaction (a group of steps that succeed or fail together) that the leaderboard is open. A trigger (automatic database check) can repeat this. |
| 7 | A query takes each player’s highest score on a leaderboard. It orders by score descending, then score_updated_at ascending. Equal scores and times are ordered by lower player_id. |
| 8 | The composite PK allows each player to earn an achievement once, and the unique code makes each achievement identifiable. A key cannot compare dates across tables, so a trigger or transaction rejects awarded_at earlier than the player’s registered_at. |
