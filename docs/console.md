Also checkout this file for examples: https://github.com/curzonj/spacebox-npc-agent/blob/master/src/common_setup.js

* This will show you the current state of the world/spodb as the console agent understands it from the websockets stream.

	`world`
	
* A list of all blueprints.

	`blueprints`

* This spawns a starter ship for you with some stuff in it.

	`cmd('spawnStarter')`

	
* This returns the inventory. After any command with `then(logit)` runs the result will be accessible in `ret`.

	`
	C.request("tech", 'GET', 200, '/inventory').then(logit).fail(logit)
	`

* Start a build job

	`
	C.request('tech', 'POST', 201, '/jobs', {
        target: what,
        facility: where,
        action: 'manufacture|refine|construct',
        quantity: how_many,
        slice: 'default'
    }).then(logit);
    `

* Deploy a scaffold

	`cmd('deploy', { shipID: from_were, slice: 'default', blueprint: what })`
	
* Transfer inventory from one location to another.

	`
	C.request("tech", "POST", 204, "/inventory", [
		{ inventory: from_where, slice: 'default', blueprint: what, quantity: how_many },
		{ inventory: to_where, slice: 'default', blueprint: what, quantity: how_many }
	]).then(logit);
	`

* Unpack a ship to make a unique ship

	`
	C.request("tech", "POST", 200, "/ships", {
		inventory: 'uuid',
		slice: 'default',
		blueprint: 'uuid'
	}).then(logit);
	
* When you refit a structure or ship and remove only some of a blueprint, the related facilities are disabled and you have to pick which one to delete.

	`
	C.request('tech', 'delete', 204, '/facilities/106e8fac-fde8-11e4-898a-6003089d765e').then(logit).fail(logit)
	`
	
* After you delete the facilities, make another call to get the system to reenable the remaining facilities.

	`
	C.request('tech', 'post', 200, '/facilities', { container_id: '08569710-fde8-11e4-af81-358649381d17' }).then(logit).fail(logit)
	`
	
* Shoot something.

	`
	cmd('shoot', { subject: uuid, target: other_uuid, })
	`

	