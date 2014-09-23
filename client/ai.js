'use strict';

var WebSocket = require('ws');

var urlUtil = require("url");
var Q = require('q');
var qhttp = require("q-io/http");

var auth_token;
function getAuthToken() {
    return Q.fcall(function() {
        var now = new Date().getTime();

        if (auth_token !== undefined && auth_token.expires > now) {
            return auth_token.token;
        } else {
            return qhttp.read({
                url: process.env.AUTH_URL + '/auth?ttl=3600',
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": 'Basic ' + new Buffer(process.env.INTERNAL_CREDS).toString('base64')
                }
            }).then(function(b) {
                auth_token = JSON.parse(b.toString());
                return auth_token.token;
            });
        }
    });
}

getAuthToken().then(function(token) {
    var url = urlUtil.parse(process.env.SPODB_URL);
    var ws = new WebSocket('ws://'+url.host+'/', {
        headers: {
            "Authorization": "Bearer " + token,
        }
    });

    ws.on('message', function(message) {
      console.log('received: %s', message);
    });

    ws.on('error', function(error) {
        console.log("error: %s", error);
    });

    var deferred = Q.defer();
    ws.on('open', function() {
        deferred.resolve(ws);
    });
    return deferred.promise;
}).then(function(ws) {
    ws.send(JSON.stringify({
        command: "spawn"
    }));
}).done();
