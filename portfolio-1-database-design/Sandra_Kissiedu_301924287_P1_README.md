# Portfolio 1 Database Design and Modelling

**Case study**

A real-time game leaderboard system stores players, game sessions, scores, rankings, and achievements. Players play sessions that produce scores, which the system ranks on a leaderboard. Administrators manage leaderboards and award achievements.

**Users**

Players take part in sessions, update their scores and view rankings and achievements. Administrators create, open and close leaderboards and define achievements.

**Main operations**

Register a player; start a session; update a score; retrieve a ranking; manage a leaderboard (create, open or close it); award an achievement; view a player’s achievements.

**Business rules**

1. Each player has a unique player ID and a unique username.

2. Each leaderboard has a unique ID and a status of open or closed.

3. Each session refers to one existing player and one existing leaderboard. The end time, once set, must be later than the start time.

4. A player can have only one active session per leaderboard at a time.

5. Each session has one current score, which is a non-negative whole number. The score can be updated only while the session is active.

6. A closed leaderboard accepts no new sessions or score updates.

7. A player has at most one ranking entry per leaderboard, based on their highest session score. Tied scores rank the earlier achieved score first.

8. Each achievement has a unique code, and a player can earn it only once. The award date cannot be earlier than the player’s registration date.

**Scope**

The system covers one fictional game service with fictional players, sessions, scores, and achievements. Rankings are derived from stored scores. Live network streaming, anti-cheat detection, authentication, payments, rewards, teams and friend lists are excluded.
## Design and implementation files

| File | Contents |
| --- | --- |
| [Design](Sandra_Kissiedu_301924287_P1_Design.md) | Entities, attributes, keys and relationships. |
| [ER diagram](Sandra_Kissiedu_301924287_P1_ERDiagram.md) | The five tables and their relationships. |
| [Normalisation](Sandra_Kissiedu_301924287_P1_Normalisation.md) | Example tables showing 1NF, 2NF and 3NF. |
| [Schema](Sandra_Kissiedu_301924287_P1_Schema.sql) | Table definitions, keys and constraints. |
| [Sample records](Sandra_Kissiedu_301924287_P1_SampleData.sql) | Fictional player, leaderboard, game_session, achievement and player_achievement. |
| [Constraint tests](Sandra_Kissiedu_301924287_P1_ConstraintTests.sql) | Invalid inserts and the final count query. |
| [Screenshots](screenshots/) | Saved commands and results. |

## Implementation

The database runs on PostgreSQL 16 and is named game_leaderboard_portfolio. It contains player, leaderboard, game_session, achievement and player_achievement. Each table has a primary key, and player_achievement uses a composite key of player_id and achievement_id. Foreign keys connect sessions to players and leaderboards, and connect player_achievement rows to players and achievements.

Usernames and achievement codes are unique. Checks restrict leaderboard status to open or closed, reject negative scores, and require ended_at to be later than started_at. A unique partial index prevents a player from having two active sessions (ended_at is empty) on the same leaderboard. The schema and sample records were committed before the invalid inserts were tested separately.

## Test results

Six invalid inserts were rejected: a missing username, a repeated username, a session linked to a nonexistent player, a negative score, an end time earlier than the start time and a second active session for the same player on the same leaderboard (ana_demo on Spring Open Board).

The final counts are 4 players, 3 leaderboards, 2 achievements, 6 sessions and 3 player achievements. The failed inserts added no rows. Of the six sessions, four are ended and two are active.

Three rules are not enforced by the table definitions alone: ended sessions cannot have their scores changed, sessions and score updates are allowed only on open leaderboards, and awarded_at cannot be earlier than registered_at. They need transaction logic or triggers, which are left for a later portfolio. Rankings (rule 7) come from a query and are not stored.

Reference: [PostgreSQL constraints](https://www.postgresql.org/docs/16/ddl-constraints.html)