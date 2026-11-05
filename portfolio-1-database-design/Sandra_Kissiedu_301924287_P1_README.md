Case study

A real-time game leaderboard system stores players, game sessions, scores, rankings and achievements. Players play sessions that produce scores, which the system ranks on a leaderboard. Administrators manage leaderboards and award achievements.

Users

Players take part in sessions, update their scores and view rankings and achievements. Administrators create, open and close leaderboards and define achievements.

Main operations

Register a player; start a session; update a score; retrieve a ranking; manage a leaderboard (create, open or close it); award an achievement; view a player’s achievements.

Business rules
Each player has a unique player ID and a unique username.
Each leaderboard has a unique ID and a status of open or closed.
Each session refers to one existing player and one existing leaderboard. The end time, once set, must be later than the start time.
A player can have only one active session per leaderboard at a time.
Each session has one current score, which is a non-negative whole number. The score can be updated only while the session is active.
A closed leaderboard accepts no new sessions or score updates.
A player has at most one ranking entry per leaderboard, based on their highest session score. Tied scores rank the earlier achieved score first.
Each achievement has a unique code, and a player can earn it only once. The award date cannot be earlier than the player’s registration date.
Scope

The system covers one fictional game service with fictional players, sessions, scores and achievements. Rankings are derived from stored scores. Live network streaming, anti-cheat detection, authentication, payments, rewards, teams and friend lists are excluded.