# Real-time Game Leaderboard Database Normalisation

Normalisation separates information into related tables to reduce repeated details and avoid inconsistent updates. The same two players, two leaderboards, three sessions and two achievements are used throughout. Only the fields needed to explain each change are shown at the early stages. The final tables show every field from my design.

Timestamps are shortened to the minute for readability. The real columns are TIMESTAMPTZ. An empty cell means the value is missing (NULL). Usernames and values are fictional examples for explanation only.

## Starting player list

| player_id | username | registered_at | Sessions | Achievements |
| --- | --- | --- | --- | --- |
| 1 | ana_k | 2026-09-01 09:00 | Session 100: board 1, Weekly Sprint (open), started 2026-10-01 10:00, ended 2026-10-01 10:30, score 450, score updated 2026-10-01 10:25; Session 101: board 2, Night Run (open), started 2026-10-02 20:00, not ended, score 120, score updated 2026-10-02 20:10 | Achievement 7: FIRST_WIN, First Win, "Finish a first session", awarded 2026-10-01 10:30; Achievement 8: HIGH_SCORE, High Scorer, "Score 400 or more", awarded 2026-10-01 10:25 |
| 2 | ben_o | 2026-09-05 09:00 | Session 102: board 1, Weekly Sprint (open), started 2026-10-01 11:00, ended 2026-10-01 11:40, score 380, score updated 2026-10-01 11:35 | Achievement 7: FIRST_WIN, First Win, "Finish a first session", awarded 2026-10-01 11:40 |

Ana's row contains two sessions and two achievements in single cells. Finding one session, updating one score or ending one session means searching inside a cell. The two lists are also unrelated to each other: a session is not linked to a particular achievement.

## 1NF: One value per cell

First normal form (1NF) means each cell holds one value and there are no repeated lists. Each session and each awarded achievement gets its own row. The two lists are unrelated, so they go in two separate tables. Placing them in one table would pair every session with every achievement and create false combinations.

### Session rows

Key: **(player_id, leaderboard_id, started_at)**. A key is the field or fields that identify one row. A key made of several fields is a combined key.

| player_id | username | registered_at | leaderboard_id | leaderboard_name | status | started_at | ended_at | score | score_updated_at |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | ana_k | 2026-09-01 09:00 | 1 | Weekly Sprint | open | 2026-10-01 10:00 | 2026-10-01 10:30 | 450 | 2026-10-01 10:25 |
| 1 | ana_k | 2026-09-01 09:00 | 2 | Night Run | open | 2026-10-02 20:00 | | 120 | 2026-10-02 20:10 |
| 2 | ben_o | 2026-09-05 09:00 | 1 | Weekly Sprint | open | 2026-10-01 11:00 | 2026-10-01 11:40 | 380 | 2026-10-01 11:35 |

The example key assumes a player cannot start two sessions on the same board at the same instant. Rows 1 and 2 share player_id 1, so player_id alone is not enough. The same board can also be played again later by the same player, so started_at is needed too. A missing ended_at is allowed here. It means the session is still active.

### Achievement rows

Key: **(player_id, achievement_id)**. A player earns each achievement once, so the pair identifies one award.

| player_id | username | registered_at | achievement_id | code | title | description | awarded_at |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | ana_k | 2026-09-01 09:00 | 7 | FIRST_WIN | First Win | Finish a first session | 2026-10-01 10:30 |
| 1 | ana_k | 2026-09-01 09:00 | 8 | HIGH_SCORE | High Scorer | Score 400 or more | 2026-10-01 10:25 |
| 2 | ben_o | 2026-09-05 09:00 | 7 | FIRST_WIN | First Win | Finish a first session | 2026-10-01 11:40 |

**What moved:** the repeated lists became separate rows.
**Why:** each session or award can now be found, added or changed on its own.
**Problem removed:** values hidden inside a cell.

Repeated details remain. Ana's username appears in several rows. Weekly Sprint's name and status repeat for Ana and Ben. The First Win details repeat for Ana and Ben. Renaming the board or closing it means changing every related row, and missing one leaves the data inconsistent.

## 2NF: Details depend on the whole key

Second normal form (2NF) includes 1NF. A non-key field must depend on the whole key, not on only part of a combined key. A field that depends on only part of the key is a partial dependency.

**Session rows.** The fields split into two groups:
- **player_id alone** determines username and registered_at. These describe the player, not one session.
- **leaderboard_id alone** determines leaderboard_name and status. These describe the board, not one session.
- **The whole key** determines ended_at, score and score_updated_at. These belong to one particular session.

**Achievement rows.** The fields split the same way:
- **player_id alone** determines username and registered_at.
- **achievement_id alone** determines code, title and description. These describe the achievement, not one award.
- **The whole key** determines awarded_at. It records when this player earned this achievement.

The partial dependencies move into their own tables.

### player

Key: **player_id**.

| player_id | username | registered_at |
| --- | --- | --- |
| 1 | ana_k | 2026-09-01 09:00 |
| 2 | ben_o | 2026-09-05 09:00 |

### leaderboard

Key: **leaderboard_id**.

| leaderboard_id | leaderboard_name | status |
| --- | --- | --- |
| 1 | Weekly Sprint | open |
| 2 | Night Run | open |

The name column is called leaderboard_name here to avoid confusion with other names. It is called name in the final design.

### achievement

Key: **achievement_id**.

| achievement_id | code | title | description |
| --- | --- | --- | --- |
| 7 | FIRST_WIN | First Win | Finish a first session |
| 8 | HIGH_SCORE | High Scorer | Score 400 or more |

### Session details

Key: **(player_id, leaderboard_id, started_at)**. player_id and leaderboard_id link to the tables above.

| player_id | leaderboard_id | started_at | ended_at | score | score_updated_at |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 2026-10-01 10:00 | 2026-10-01 10:30 | 450 | 2026-10-01 10:25 |
| 1 | 2 | 2026-10-02 20:00 | | 120 | 2026-10-02 20:10 |
| 2 | 1 | 2026-10-01 11:00 | 2026-10-01 11:40 | 380 | 2026-10-01 11:35 |

### Award details

Key: **(player_id, achievement_id)**. Both fields link to other tables.

| player_id | achievement_id | awarded_at |
| --- | --- | --- |
| 1 | 7 | 2026-10-01 10:30 |
| 1 | 8 | 2026-10-01 10:25 |
| 2 | 7 | 2026-10-01 11:40 |

**What moved:** player, board and achievement details.
**Why:** each describes one thing, whatever sessions or awards involve it.
**Problems removed:** Ana's username is now stored once, even though both her sessions and her awards need it. Weekly Sprint is stored once, so renaming it or closing it changes one row. First Win is stored once. A new player, board or achievement can also be recorded before any session or award exists.

## 3NF: Keep details with the thing they describe

Third normal form (3NF) includes 2NF. A non-key field must not depend on another non-key field. If it did, the dependent field would belong in its own table.

Each table is checked in turn:

* **player:** username and registered_at each describe the player. Neither determines the other. username is unique, so it can also identify a player, but it is an alternative identifier and not a repeated detail.
* **leaderboard:** the name and the open or closed status are independent. Knowing the name does not tell the status.
* **achievement:** title and description describe the achievement. code is unique, so it identifies the same row as achievement_id. That is acceptable, because it is an identifier and not a separate fact.
* **Session details:** ended_at, score and score_updated_at each describe the one session. None determines another.
* **Award details:** awarded_at is the only non-key field.

No field depends on another non-key field, so the tables are already in 3NF. No further separation is needed, and none is invented here.

My design also does not store a ranking. A stored rank would depend on the scores of other sessions, not on one session. It would become out of date whenever a score changes. Rankings are calculated from the session rows when needed.

## My design: IDs replace the example combined key

The example key (player_id, leaderboard_id, started_at) works, but it is long, and the final design replaces it. game_session uses an automatically generated **session_id** as its primary key. The reasons are:
- A single value is simpler to reference.
- It stays stable if started_at is ever corrected.
- player_id and leaderboard_id remain **foreign keys**, which are fields that point to a row's primary key in another table.

This is a design choice. It is not what makes the table 3NF. An ID alone does not prove 3NF, because a table with an ID can still hold repeated or dependent details. The table is in 3NF because of the dependency checks above. player_achievement keeps its combined key (player_id, achievement_id), because the pair already identifies one award and rule 8 allows each player to earn an achievement once.

IDs keep the tables linked. Session 100 points to player 1 and board 1, so a query can bring back ana_k and Weekly Sprint for that session without storing them again.

## Final tables

All fields in my design are shown below, so none are left out. Only the timestamps are shortened.

### player

PK: player_id.

| player_id | username | registered_at |
| --- | --- | --- |
| 1 | ana_k | 2026-09-01 09:00 |
| 2 | ben_o | 2026-09-05 09:00 |

### leaderboard

PK: leaderboard_id.

| leaderboard_id | name | status |
| --- | --- | --- |
| 1 | Weekly Sprint | open |
| 2 | Night Run | open |

### game_session

PK: session_id. FKs: player_id and leaderboard_id.

| session_id | player_id | leaderboard_id | started_at | ended_at | score | score_updated_at |
| --- | --- | --- | --- | --- | --- | --- |
| 100 | 1 | 1 | 2026-10-01 10:00 | 2026-10-01 10:30 | 450 | 2026-10-01 10:25 |
| 101 | 1 | 2 | 2026-10-02 20:00 | | 120 | 2026-10-02 20:10 |
| 102 | 2 | 1 | 2026-10-01 11:00 | 2026-10-01 11:40 | 380 | 2026-10-01 11:35 |

### achievement

PK: achievement_id. Unique: code.

| achievement_id | code | title | description |
| --- | --- | --- | --- |
| 7 | FIRST_WIN | First Win | Finish a first session |
| 8 | HIGH_SCORE | High Scorer | Score 400 or more |

### player_achievement

PK: (player_id, achievement_id). FKs: player_id and achievement_id.

| player_id | achievement_id | awarded_at |
| --- | --- | --- |
| 1 | 7 | 2026-10-01 10:30 |
| 1 | 8 | 2026-10-01 10:25 |
| 2 | 7 | 2026-10-01 11:40 |

Normalisation does not enforce every business rule. Unique usernames and codes, the open or closed status check, score of at least 0, ended_at later than started_at, only one active session per player on each board, the open-board check and awarded_at not earlier than registered_at are all still needed as separate checks. These are the unique constraints, checks, unique index, transactions and triggers in my design.