* This will show you the current state of the world/spodb as the console agent understands it from the websockets stream.

	`world`
	
* A list of all blueprints.

	`blueprints`

* This spawns a starter ship for you with some stuff in it.

	`cmd('spawnStarter')`

	
* This returns the inventory. After any command with `then(logit)` runs the result will be accessible in `ret`.

	`
	C.request("inventory", 'GET', 200, '/inventory').then(logit)
	`

* Start a build job

	`
	C.request('build', 'POST', 201, '/jobs', {
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
	C.request("inventory", "POST", 204, "/inventory", [
		{ inventory: from_where, slice: 'default', blueprint: what, quantity: how_many },
		{ inventory: to_where, slice: 'default', blueprint: what, quantity: how_many }
	]).then(logit);
	`
	