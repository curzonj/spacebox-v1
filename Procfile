auth: node auth/src/server.js | ./common/bin/bunyan -o short
api: FILE_LOG_LEVEL=trace node api/src/server.js | ./common/bin/bunyan -o short
firehose: node 3dsim/src/fe/main.js | ./common/bin/bunyan -o short
worker: node api/src/worker/main.js | ./common/bin/bunyan -o short
3dsim: WTF=1 node 3dsim/src/sim/main.js | ./common/bin/bunyan -o short
