* `cmd('spawnStarter')`

	Seed the game with some starter stuff

* `C.request("inventory", 'GET', 200, '/inventory').then(logit)`

	This returns the inventory

* `C.request('build', 'POST', 201, '/jobs', {
        target: what,
        facility: where,
        action: how,
        quantity: how_many,
        slice: 'default'
    });`