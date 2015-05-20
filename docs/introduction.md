Spacebox is an MMO in the style of EVE Online. Some differences are:

* It's so alpha that comparing it to EVE may sound more like a joke than reality.
* It's api-first/api-only. There is no UI yet and game features will be prioritized over the UI. There is a nodejs repl console that you can use to get started and you are encouraged to bot and/or automate any aspect of the game.

All my game design work is happening on [this trello board](https://trello.com/b/r3BCdYOs/spacebox) which anybody may request access to.

I will try to maintain a [changelog](../CHANGELOG.md) that you can read to know about changes.

#### Architecture

Spacebox is composed of 3 services:

* 3dsim - You connect to this via websockets. It sends messages about the state of space around you and you send commands that change that space, like docking and shooting.
* tech - You make REST api calls to this to manipulate inventory and start jobs. It also has a websocket endpoint that you can receive realtime updates from about the progress of jobs and changes to facilities.
* auth - You request a Json Web Token from here and pass it as `Bearer` authentication to the other services.

These services are all written in nodejs because at the time I wanted to work in the same language on the backend as I was using for the three.js frontend. The apps are deployed to heroku using postgresql for persistence.

Friends, if you want collaborator rights on the apps for debugging the endless bugs you'll experience or pushing fixes ping me.


#### Current Game Design

The TL;DR is that you can receive resources, build ships and space stations, move your ships through wormholes, and blow thnigs up.

* You can spawn a single starter ship. You'll be able to spawn another each time your reset your game account. Resetting your game account deletes everything of yours in the game world.
* Your ship has a `position` and a `solar_system`. Position is basically ignored right now, but you can only see things in the same solar_system as you.
* Your ship has an `inventory` which has `facilities`.
* Inventories have slices. The plan is to use them for organization. Right now basically everything just refers to the `default` slice.
* Your starter ship starts off with metal in the inventory. You can use that to start a `job` in the facility in your ship to make a `scaffold`.
* You `deploy` the scaffold, `dock` with it, transfer some metal to the scaffold, then start a job to `construct` a `Basic Outpost`.
* While that happens you can start 2 more jobs to build `modules`. The only two current modules are a `Factory` and an `Ore Mine`.
* Currently only the starter ship can refine `Ore` to `Metal`.
* The factory can build fighters and scaffolds at the moment.
* When you build a ship it starts as just a counter in the inventory. To make it a fully defined ship with a uuid that you can undock you have to unpack it.
* Ships can `scanWormholes` which will expose wormholes in the world state. You can then tell a ship to `jumpWormhole` to move it to another solar system.
* Wormholes have a short TTL which is certain to change as I tune the system. As of this writing it's 15 seconds, but I plan on moving it to 2 minutes shortly.
* There are 100 solar systems and each one has about 4 wormholes at a time. That should be enough to give you places to hide and run away. 
* Ship weapons do a certain amount of damage per world tick (about 80ms). You tell your ship to `shoot` something else and when it's `health` drops to zero it will be destroyed. You'll receive a notification via world state.
* When something disappears, in world state or facilities, you'll get an update which `tombstone=true`, and for world state, `tombstone_cause=SOMETHING`. A tombstone record is the last update you'll receive for an object and it's assumed you delete it from your state tracking.


The definition of everything in the game world and what can build what comes from [this file](https://github.com/curzonj/spacebox-tech/blob/master/src/blueprint_demo.js) until the research system is built.

#### Reading the code 

The easiest way to interact with the game or to figure out how to write your own interfaces is by using and reading the code for the console.

* First thing you'll notice is that uuids are everywhere. Everything is represented by one. You'll see some helper methods used in the console to avoid hardcoding UUIDs in. You'll also see lots of UUIDs hardcoded.

* This file is the actual console. It keeps track of the world state by processing websocket messages from 3dsim and tech.
	
	```
	https://github.com/curzonj/spacebox-npc-agent/blob/master/console.js
	```

* This file scripts a number of different scenarios. It uses nodejs promises to orchestrate things. `ctx` refers to the console itself, so you can remove that when running the commands by hand.

	```
	https://github.com/curzonj/spacebox-npc-agent/blob/master/src/common_setup.js
	```

* This file is shared code across the project and contains the code for making API requests to the services in case you want to build your bots in another language.

	```
	https://github.com/curzonj/spacebox-nodejs-common/blob/master/main.js#L206
	```