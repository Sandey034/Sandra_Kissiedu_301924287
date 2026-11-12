# Portfolio 3 Transactions and Concurrency

## Commit and rollback

In one transaction, I raised the score of active session 2 from 900 to 1800 and committed it. The update only applies while the session is active, still at 900 and on an open leaderboard, so it cannot be applied twice. In a second transaction, I changed active session 3 from 0 to 400, then tried to set a score of -50. PostgreSQL rejected it with `ck_game_session_score`, and `ROLLBACK` undid the whole transaction. The final query showed session 2 at 1800 and session 3 back at 0. This shows that a transaction keeps or discards its changes as one unit. The table definitions alone do not stop updates to ended sessions or to closed leaderboards, so those rules need update conditions like the one above.

## Isolation and concurrency control

Both connections used `READ COMMITTED`, which I set and displayed with `SHOW transaction_isolation`. Session A inserted an active session for dev_demo on Spring Open Board without committing. Session B could not see it, and its own check counted 0 active sessions. When B tried the same insert, it had to wait for A. After A committed, B failed with a duplicate key error on `uq_game_session_active`, and B rolled back. The final query showed one active session for dev_demo on that board. The unique partial index prevented the conflict, not the isolation level, because B's earlier check had seen no session. The test covers rule 4 only. Rules 5 and 6 have no constraint behind them, so they would need explicit locking or triggers.

## Conclusion

The exercises showed that commit keeps a change and rollback discards a failed transaction's changes. They also showed that rule 4 held under two connections because of the unique partial index. Concurrent updates to ended sessions and sessions on closed leaderboards were not tested and are not protected by the current schema.

## Files

- [Commit and rollback SQL](Sandra_Kissiedu_301924287_P3_Transactions.sql)
- [Session A](Sandra_Kissiedu_301924287_StudentID_P3_SessionA.sql)
- [Session B](Sandra_Kissiedu_301924287_StudentID_P3_SessionB.sql)
- [Screenshots](screenshots/)

## References

- [PostgreSQL 16: Transactions](https://www.postgresql.org/docs/16/tutorial-transactions.html)
- [PostgreSQL 16: Transaction Isolation](https://www.postgresql.org/docs/16/transaction-iso.html)
- [PostgreSQL 16: Unique Indexes](https://www.postgresql.org/docs/16/indexes-unique.html)