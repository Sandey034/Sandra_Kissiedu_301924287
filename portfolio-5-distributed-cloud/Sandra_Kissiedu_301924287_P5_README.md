# Portfolio 5 Distributed and Cloud Database Exercise

## Current setup

My files show one local MongoDB 8.0.38 instance running in a GitHub Codespace. It was started with `mongod --fork` and I connected with `mongosh "mongodb://127.0.0.1:27017"`. The database `game_leaderboard_nosql` holds the collection `activity_events` with four fictional events from Portfolio 4. The start command has no replica set option, so this looks like a single node, but I have not verified the topology with a status command. PostgreSQL 16 (Portfolio 1) is a separate database. Nothing below has been implemented.

## Proposed replication

I propose a three-member [replica set](https://www.mongodb.com/docs/manual/replication/). All members would vote, hold data and run on separate hosts in different failure zones.

| Member | Starting role | Location |
| --- | --- | --- |
| mongo-a | Primary | Host 1, zone A |
| mongo-b | Secondary | Host 2, zone B |
| mongo-c | Secondary | Host 3, zone C |

For example, a `score_update` event such as `evt-0001` for ana_demo would be written to mongo-a and copied to mongo-b and mongo-c.

## Failure and consistency

If mongo-a becomes unreachable for longer than the timeout, the secondaries [hold an election](https://www.mongodb.com/docs/v8.0/core/replica-set-elections/) and one becomes primary. The documentation gives a default timeout of 10 seconds. Writes stop until the election finishes, so there is a brief interruption. I have not tested failover or measured any times.

A new primary needs votes from a majority (2 of 3). If only one member is reachable, no primary is elected and writes stop. A primary that can only see a minority steps down.

With [write concern](https://www.mongodb.com/docs/v8.0/reference/write-concern/) `majority`, MongoDB confirms a write only after most members have it, so an acknowledged `evt-0001` should survive losing one member. Secondaries can lag, so a read from a secondary may miss the newest event.

Decisions such as whether a leaderboard is open, whether a session is active and what a ranking is would stay in PostgreSQL, the authoritative database. MongoDB would hold the event history only.

## Sharding and cloud deployment

Replication copies the same data to every member. [Sharding](https://www.mongodb.com/docs/manual/sharding/) splits records across shards, so each shard holds only part of the collection. My four events do not need sharding, and one replica set is enough for this size. Sharding would only be considered if the event history grew very large.

On a cloud service such as Atlas, I would require authentication, encrypted connections and storage, and restrict network access to known addresses. I would use [backup and restore](https://www.mongodb.com/docs/atlas/backup-restore-cluster/) and test a restore before relying on it. More members, storage and backups cost more, which is a poor fit for a small coursework example.

Limitation: MongoDB replication only copies data between MongoDB members. It does not replicate PostgreSQL or keep the two databases in sync, so any link between them would need separate work.

## References

* [MongoDB — Replication](https://www.mongodb.com/docs/manual/replication/)
* [MongoDB 8.0 — Replica Set Elections](https://www.mongodb.com/docs/v8.0/core/replica-set-elections/)
* [MongoDB 8.0 — Write Concern](https://www.mongodb.com/docs/v8.0/reference/write-concern/)
* [MongoDB — Sharding](https://www.mongodb.com/docs/manual/sharding/)
* [Atlas — Back Up and Restore a Cluster](https://www.mongodb.com/docs/atlas/backup-restore-cluster/)