This directory has a bunch of test bots that do something to make sure it works. They do it the real way and are things that normal users will want to do, so it's a good example. `ctx` refers to the console itself, so you can remove that when running the commands by hand.

	```
	https://github.com/curzonj/spacebox-npc-agent/blob/master/tests
	```

* This will show you the current state of the world/spodb as the console agent understands it from the websockets stream.

	`world`
	
* A list of all blueprints.

	`blueprints`
	
* If you've played with stuff before, you may want to reset your account. This will delete any ships, structures, inventories, etc in the game universe on your account.

	`
	cmd('resetAccount')
	`

* This spawns a starter ship for you with some stuff in it.

	`cmd('spawnStarter')`
	
* This returns the inventory. After any command with `then(logit)` runs the result will be accessible in `ret`.

	`
	client.request("api", 'GET', 200, '/inventory').then(logit).fail(logit)
	`

* Start a build job

	`
	client.request('api', 'POST', 201, '/jobs', {
        target: what,
        facility: where,
        quantity: how_many,
        slice: 'default'
    }).then(logit);
    `

* Deploy something, a ship, a space crate, etc.

	`cmd('deploy', { shipID: from_were, slice: 'default', blueprint: what })`
	
	OR
	
	`cmd('deploy', { shipID: from_were, slice: 'default', blueprint: vessel_blueprint_uuid, vessel_uuid: uuid })`
	
* Transfer inventory from one location to another.

	`
	client.request("api", "POST", 204, "/inventory", {
        from_id: where_uuid, from_slice: 'default',
        to_id: where_uuid, to_slice: 'default',
        items: [{
            blueprint: what_uuid, quantity: how_many
        }, {
            blueprint: what_uuid, quantity: how_many
        }]
    }).then(ctx.logit)
	`

* Unpack a ship to make a unique ship

	`
	client.request("api", "POST", 200, "/items", {
		inventory: 'uuid',
		slice: 'default',
		blueprint: 'uuid'
	}).then(logit)
	`
	
* When you refit a structure or ship and remove only some of a blueprint, the related facilities are disabled and you have to pick which one to delete.

	`
	client.request('api', 'delete', 204, '/facilities/106e8fac-fde8-11e4-898a-6003089d765e').then(logit).fail(logit)
	`
	
* After you delete the facilities, make another call to get the system to reenable the remaining facilities.

	`
	client.request('api', 'post', 200, '/facilities', { container_id: '08569710-fde8-11e4-af81-358649381d17' }).then(logit).fail(logit)
	`
	
* Shoot something.

	`
	cmd('shoot', { vessel: uuid, target: other_uuid, })
	`

	
