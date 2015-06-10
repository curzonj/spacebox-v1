auth: node auth/src/server.js
api: node api/src/server.js | tee logs/api.log
firehose: node 3dsim/src/main.js
worker: node api/src/worker/main.js
3dsim: node 3dsim/src/sim/main.js
sim_worker: node 3dsim/src/worker/main.js
redis: redis-server | tee logs/redis.log
