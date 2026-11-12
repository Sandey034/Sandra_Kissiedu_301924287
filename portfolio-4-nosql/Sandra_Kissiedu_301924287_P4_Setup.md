# MongoDB setup

MongoDB runs in the existing Ubuntu Codespace, alongside PostgreSQL.
The server version is 8.0.38. Its data folder is /workspaces/mongodb-data,
outside the repository. Connections use 127.0.0.1; port forwarding is off.

## Start and connect

```bash
mongod --dbpath /workspaces/mongodb-data --logpath /workspaces/mongodb-data/mongod.log --logappend --bind_ip 127.0.0.1 --fork
mongosh "mongodb://127.0.0.1:27017"
```

## Connection check

db.version() returns 8.0.38 and db.runCommand({ ping: 1 }) returns { ok: 1 }.

![MongoDB connection]( /workspaces/Sandra_Kissiedu_301924287/portfolio-4-nosql/screenshots/Sandra_Kissiedu_301924287_P4_MongoDBConnection.png)

## Reference

[MongoDB Ubuntu installation guide](https://www.mongodb.com/docs/v8.0/tutorial/install-mongodb-on-ubuntu/)

[MongoDB 8.0 — mongod startup options](https://www.mongodb.com/docs/v8.0/reference/program/mongod/)
