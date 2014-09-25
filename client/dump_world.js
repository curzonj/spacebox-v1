'use strict';

var WebSocket = require('ws');

var urlUtil = require("url");
var Q = require('q');
var qhttp = require("q-io/http");
var deepMerge = require('./deepMerge');
var EventEmitter = require('events').EventEmitter;


var ws;
var clientAuth;
var gameReady = Q.defer();
var game = new EventEmitter();

game.world = {};
game.byAccount = {};

function getAuthToken() {
    return Q.fcall(function() {
        var now = new Date().getTime();

        if (clientAuth !== undefined && clientAuth.expires > now) {
            return clientAuth.token;
        } else {
            return qhttp.read({
                url: process.env.AUTH_URL + '/auth?ttl=3600',
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": 'Basic ' + new Buffer(process.env.INTERNAL_CREDS).toString('base64')
                }
            }).then(function(b) {
                clientAuth = JSON.parse(b.toString());
                return clientAuth.token;
            });
        }
    });
}

getAuthToken().then(function(token) {
    console.log("authenticated, connecting");

    var url = urlUtil.parse(process.env.SPODB_URL);
    ws = new WebSocket('ws://'+url.host+'/', {
        headers: {
            "Authorization": 'Bearer ' + token
        
        }
    });
}).then(function() {
    ws.on('message', handleMessage);
    ws.on('error', function(error) {
        console.log("error: %s", error);
    });
});


//"Authorization": "Bearer " + token,


function handleMessage(message) {
    var data;

    try {
        data = JSON.parse(message);
    } catch(e) {
        console.log("invalid json: %s", message);
        return;
    }

    //console.log(message);

    switch (data.type) {
        case "arenaAccount":
            clientAuth = data.account;
            break;
        case "connectionReady":
            game.emit('ready');
            break;
        case "state":
            game.world[data.state.key] = deepMerge(data.state.values, game[data.state.key]);

            if (game.world[data.state.key].tombstone === true) {
                var data_account = game.world[data.state.key].account;

                if (data_account !== undefined && game.byAccount[data_account] !== undefined) {
                    var i = game.byAccount[data_account].indexOf(data.state.key);

                    if (i > -1) {
                        game.byAccount[data.state.values.account].splice(i, 1);
                    }
                } else {
                    console.log("unable to remove from account list "+data.state.key);
                }

                delete game.world[data.state.key];
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

}

game.on('ready', function() {
    console.log(game.world);
    ws.terminate();
});
