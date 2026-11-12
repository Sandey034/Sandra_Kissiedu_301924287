# Portfolio 4 NoSQL and Advanced Data Models

## Document model

This portfolio adds a separate MongoDB example for the game leaderboard case. The data is fictional and was written by hand for MongoDB. It is not automatically extracted from the PostgreSQL database, and PostgreSQL was not changed. The player, leaderboard, session and achievement IDs reuse the Portfolio 1 sample records.

The database is `game_leaderboard_nosql` and the collection is `activity_events`. Every event has the shared fields `_id`, `eventType` and `occurredAt`, plus an embedded `player` document. The `details` section varies by event type: a `score_update` holds the session, an embedded leaderboard, and the previous and new score, while an `achievement_awarded` holds the achievement ID, code and title.

Example document:

```javascript
{
  _id: "evt-0002",
  eventType: "achievement_awarded",
  occurredAt: ISODate("2026-03-01T10:31:00Z"),
  player: { playerId: 1, username: "ana_demo" },
  details: { achievementId: 1, code: "FIRST_WIN", title: "First Win" }
}
```

## Implementation and results

A local MongoDB 8.0.38 instance was used, running in a GitHub Codespace and connected with `mongosh "mongodb://127.0.0.1:27017"`. No credentials are used or stored. The script selected `game_leaderboard_nosql`, checked that `activity_events` was empty, and inserted four documents once.

- Empty check before insert: `0`
- Insert: `acknowledged: true`, with `insertedIds` `evt-0001` to `evt-0004`
- Total count: `4`
- ana_demo's event history, oldest first: `evt-0001` (score_update, 10:25), `evt-0002` (FIRST_WIN, 10:31) and `evt-0003` (SCORE_1000, 10:32). ben_demo's event was not returned.
- Events with `details.newScore` of 1300 or more: one document, `evt-0001` (ana_demo, newScore 1500). ben_demo's 1200 is below 1300, and the achievement events have no `newScore` field.


## Why MongoDB fits

Score updates and achievement awards carry different details. In MongoDB each event holds only the fields it needs in one document, without empty columns or a separate table per event type. Related details such as the leaderboard are embedded, so one event is read in a single query, as the player history query showed. The event history is also append-only, so documents are written once and rarely changed.

Limitation: the embedded copies of `username` and leaderboard `name` are not linked to PostgreSQL. If a name changes there, old events keep the old value, and MongoDB does not enforce the foreign keys or business rules from Portfolio 1.


## Files

* [MongoDB implementation and queries](/workspaces/Sandra_Kissiedu_301924287/portfolio-4-nosql/Sandra_Kissiedu_301924287_P4_MongoDB.js)
* [Setup and connection check](/workspaces/Sandra_Kissiedu_301924287/portfolio-4-nosql/Sandra_Kissiedu_301924287_P4_Setup.md)
* [Screenshots](/workspaces/Sandra_Kissiedu_301924287/portfolio-4-nosql/screenshots): MongoDBConnection and EventsAndQueries.


## References

* [MongoDB — Data Modeling](https://www.mongodb.com/docs/manual/data-modeling/)
* [MongoDB — insertMany](https://www.mongodb.com/docs/manual/reference/method/db.collection.insertmany/)
* [MongoDB — Query Embedded Documents](https://www.mongodb.com/docs/manual/tutorial/query-embedded-documents/)