# Portfolio 2 Query Processing and Optimisation

## Queries and results

Query 1 ranks players on Spring Open Board by each player's highest score, breaking ties by the earlier score_updated_at and then the lower player_id. It returned 3 rows: ana_demo (1500), ben_demo (1200) and cara_demo (1200), with the last two tied on score and time. Query 2 uses NOT EXISTS to find players with no game sessions. It returned 1 row: dev_demo (player_id 4). Query 3 uses a LEFT JOIN to count achievements per player and keeps players with none. It returned 4 rows: ana_demo 2, ben_demo 1, cara_demo 0 and dev_demo 0.

## Index comparison

The test table is p2_benchmark.score_history, a synthetic history table with 100,000 rows (confirmed by SELECT COUNT(*)). The unchanged query selects the 60 rows with recorded_at from 2026-04-10 00:00 to 01:00 UTC, ordered by recorded_at. The added index is a B-tree index, idx_score_history_recorded_at, on recorded_at. Before the index, the plan was run once as a warm-up and then three times for measurement. After the index, the three plans shown were all counted as measurements.

| Measurement | Before index | After index |
| --- | --- | --- |
| Scan type | Seq Scan (with Sort) | Index Scan |
| Three execution times (ms) | 7.603, 10.732, 8.148 | 0.053, 0.058, 0.090 |
| Median time (ms) | 8.148 | 0.058 |
| Shared buffer hits, third run | 935 | 3 |

## Performance analysis

Before the index, PostgreSQL read the whole table with a sequential scan, removed 99,940 rows to return 60, and then sorted them. After the index, it used an index scan on recorded_at, and the shared buffer hits fell from 935 to 3. The median execution time fell from 8.148 ms to 0.058 ms. This was measured on one small, synthetic table that is fully cached, so the timings vary between runs and results on a larger or busier system may differ. Also, the first after-index run included a cold read (`read=2`) because there was no separate warm-up run after the index was created. An index does not guarantee a faster query. The index also uses extra storage, and every insert or update of recorded_at must maintain it, which slows writes.

## Files

- [Queries](Sandra_Kissiedu_301924287_P2_Queries.sql)
- [Test data, execution plans and index SQL](Sandra_Kissiedu_301924287_P2_Optimisation.sql)
- [Screenshots](Screenshots/)


## Reference

- [PostgreSQL 16: Using EXPLAIN](https://www.postgresql.org/docs/16/using-explain.html)
