Spacebox is an MMO in the style of EVE Online. Some differences are:

* It's so alpha that comparing it to EVE may sound more like a joke than reality.
* It's api-first/api-only. There is no UI yet and game features will be prioritized over the UI. There is a nodejs repl console that you can use to get started and you are encouraged to bot and/or automate any aspect of the game.

All my game design work is happening on [this trello board](https://trello.com/b/r3BCdYOs/spacebox) which anybody may request access to.

I will try to maintain a [changelog](../CHANGELOG.md) that you can read to know about changes.

#### Architecture

Spacebox is composed of 3 services:

* 3dsim - You connect to this via websockets. It sends messages about the state of space around you.
* api - You make REST api calls to this to manipulate the game in any way. It also has a websocket endpoint that you can receive realtime updates from about the progress of jobs and changes to facilities.
* auth - You request a Json Web Token from here and pass it as `Bearer` authentication to the other services.

These services are all written in nodejs because at the time I wanted to work in the same language on the backend as I was using for the three.js frontend. The apps are deployed to heroku using postgresql for persistence and redis for publishing state between the components.

Friends, if you want collaborator rights on the apps for debugging the endless bugs you'll experience or pushing fixes ping me.


#### Current Game Design

The TL;DR is that you can receive resources, build ships and space stations, move your ships through wormholes, research new blueprints, and blow things up.

* You can spawn a single starter ship. You'll be able to spawn another each time your reset your game account. Resetting your game account deletes everything of yours in the game world.
* Your ship has a `position` and a `solar_system`. You can only see things, dock, or jump through a wormhole from a certain range. Most things right now are +/- 20 on x,y,z and your sight range is 10.
* Your ship has an `inventory` which has `facilities`.
* Inventories have slices. The plan is to use them for organization. Right now basically everything just refers to the `default` slice.
* Your starter ship starts off with metal in the inventory. You can use that to start a `job` in the facility in your ship to make a `Space Crate` and another to make a `Factory` module.
* You `deploy` the Space Crate, `dock` with it, transfer some metal and the module to the space crate, then start a `construction` job to setup the factory in the space crate. Now you have another facility to run jobs at.
* The factory can build everything depending on the size of the factory and the size of the object.
* When you build a ship it starts as just a counter in the inventory. To make it a fully defined ship with a uuid you either have to undock one or unpack one of that uuid.
* Ships can `scanWormholes` which will expose wormholes in the world state. You can then tell a ship to `jumpWormhole` to move it to another solar system.
* Wormholes have a short TTL which is certain to change as I tune the system. As of this writing it's 30 seconds, but I plan on moving it to 2 minutes shortly.
* There are lots of solar systems and each one has about 4 wormholes at a time. That should be enough to give you places to hide and run away. 
* Ship weapons do a certain amount of damage per world tick (about 80ms). You tell your ship to `shoot` something else and when it's `health` drops to zero it will be destroyed. You'll receive a notification via world state.
* When something disappears, in world state or facilities, you'll get an update which `tombstone=true`, and for world state, `tombstone_cause=SOMETHING`. A tombstone record is the last update you'll receive for an object and it's assumed you delete it from your state tracking.
* You can spend metal on research jobs that produce new blueprints with better stats. These stats are based on polynomial functions that determine the resulting cost to build the item.


The definition of everything in the game world comes from [these files in github](https://github.com/curzonj/spacebox-tech/tree/master/data). Your bots/scripts can also fetch this and other data from [https://spacebox-tech.herokuapp.com/specs](https://spacebox-tech.herokuapp.com/specs).

#### Reading the code 

The easiest way to interact with the game or to figure out how to write your own interfaces is by using and reading the code for the console.

* First thing you'll notice is that uuids are everywhere. Everything is represented by one. You'll see some helper methods used in the console to avoid hardcoding UUIDs in. You'll also see lots of UUIDs hardcoded.

* This file is the actual console. It really does nothing except give you access to the helper functions that the scripts use.
	
	```
	https://github.com/curzonj/spacebox-npc-agent/blob/master/console.js
	```

* This directory has a bunch of test bots that do something to make sure it works. They do it the real way and are things that normal users will want to do, so it's a good example. `ctx` refers to the console itself, so you can remove that when running the commands by hand.

	```
	https://github.com/curzonj/spacebox-npc-agent/blob/master/tests
	```

* These files provide all the helpers that the test bots and the UI use. `ctx` in the case of the console is the global object. Be aware when running it by hand, everything uses javascript promises which means that most return values don't actually mean anything. When in doubt, add `.then(logit).fail(logit)` to the end of a value.

	```
	https://github.com/curzonj/spacebox-npc-agent/blob/master/src/helpers.js
	https://github.com/curzonj/spacebox-nodejs-common/blob/master/client.js
	```
