'use strict';

var WebSocket = require('ws');

var urlUtil = require("url");
var Q = require('q');
var qhttp = require("q-io/http");
var deepMerge = require('./deepMerge');
var EventEmitter = require('events').EventEmitter;

var url = urlUtil.parse(process.env.SPODB_URL);

// authentication to the arena is disabled atm
var ws = new WebSocket('ws://'+url.host+'/arena');

var account;
var gameReady = Q.defer();
var game = new EventEmitter();

game.world = {};
game.byAccount = {};

//"Authorization": "Bearer " + token,

ws.on('error', function(error) {
    console.log("error: %s", error);
});

ws.on('message', function(message) {
    var data;
    try {
        data = JSON.parse(message);
    } catch(e) {
        console.log("invalid json: %s", message);
    }

    console.log(message);

    switch (data.type) {
        case "arenaAccount":
            account = data.account;
            game.emit('ready');
            break;
        case "state":
            game.world[data.state.key] = deepMerge(data.state.values, game[data.state.key]);

            if (game.world[data.state.key].tombstone === true) {
                delete game.world[data.state.key];

                if (game.byAccount[data.state.values.account] !== undefined) {
                    var i = game.byAccount[data.state.values.account].indexOf(data.state.key);

                    if (i > -1) {
                        game.byAccount[data.state.values.account].splice(i, 1);
                    }
                }
            } else if (data.state.values.account !== undefined) {
                if (game.byAccount[data.state.values.account] === undefined) {
                    game.byAccount[data.state.values.account] = [];
                }

                if (game.byAccount[data.state.values.account].indexOf(data.state.key) == -1) {
                    game.byAccount[data.state.values.account].push(data.state.key);
                }
            }

            game.emit('update', data.state);
            break;
    }
});

function autoSpawn() {
    var accountList = [ account.account, "the-other-guy" ];
    var byAccount = game.byAccount;

    accountList.forEach(function(account) {
        if (byAccount[account] === undefined || byAccount[account].length === 0) {
            ws.send(JSON.stringify({ command: "spawn", account: account } ));
            ws.send(JSON.stringify({ command: "spawn", account: account } ));
        } else if (byAccount[account].length < 2) {
            ws.send(JSON.stringify({ command: "spawn", account: account } ));
        }
    });
}

game.on('ready', function() {
    setInterval(autoSpawn, 1000);
});
