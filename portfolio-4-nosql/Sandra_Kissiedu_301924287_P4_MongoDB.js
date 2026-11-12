// Connect first: mongosh "mongodb://127.0.0.1:27017"   (or your Atlas string)
// Run the steps one at a time. Do not run step 3 twice.

// 1. Select the database
db = db.getSiblingDB("game_leaderboard_nosql");

// 2. Check the collection is empty (expect 0)
db.activity_events.countDocuments({});

// 3. Insert the four documents once
db.activity_events.insertMany([
  {
    _id: "evt-0001",
    eventType: "score_update",
    occurredAt: ISODate("2026-03-01T10:25:00Z"),
    player: { playerId: 1, username: "ana_demo" },
    details: {
      sessionId: 1,
      leaderboard: { leaderboardId: 1, name: "Spring Open Board" },
      previousScore: 1200,
      newScore: 1500
    }
  },
  {
    _id: "evt-0002",
    eventType: "achievement_awarded",
    occurredAt: ISODate("2026-03-01T10:31:00Z"),
    player: { playerId: 1, username: "ana_demo" },
    details: { achievementId: 1, code: "FIRST_WIN", title: "First Win" }
  },
  {
    _id: "evt-0003",
    eventType: "achievement_awarded",
    occurredAt: ISODate("2026-03-01T10:32:00Z"),
    player: { playerId: 1, username: "ana_demo" },
    details: { achievementId: 2, code: "SCORE_1000", title: "Score 1000" }
  },
  {
    _id: "evt-0004",
    eventType: "score_update",
    occurredAt: ISODate("2026-03-01T12:30:00Z"),
    player: { playerId: 2, username: "ben_demo" },
    details: {
      sessionId: 4,
      leaderboard: { leaderboardId: 1, name: "Spring Open Board" },
      previousScore: 800,
      newScore: 1200
    }
  }
]);

// 4. Query A: total count
db.activity_events.countDocuments({});

// 5. Query B: one player's event history, oldest first
db.activity_events.find(
  { "player.playerId": 1 },
  { eventType: 1, occurredAt: 1, details: 1 }
).sort({ occurredAt: 1 });

// 6. Query C: nested-field filter (new score of 1300 or more)
db.activity_events.find({ "details.newScore": { $gte: 1300 } });