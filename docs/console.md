[This directory](https://github.com/curzonj/spacebox-npc-agent/blob/master/tests) has a bunch of test bots that do something to make sure it works. They do it the real way and are things that normal users will want to do, so it's a good example. `ctx` refers to the console itself, so you can remove that when running the commands by hand.
	
* You can find the interactive API docs here, [https://spacebox-tech.herokuapp.com/docs/](https://spacebox-tech.herokuapp.com/docs/). Any `/commands/*` endpoints can be used in the console with

	`
	cmd(name, POST_BODY)
	`
	
	You can also make api requests like this and the authentication will be handled for you:
	
	`
	client.get('/endpoint')
	`
	
	OR
	
	`
	client.post('/endpoint', POST_BODY)
	`

* This will show you the current state of the world/spodb as the console agent understands it from the websockets stream.

	`world`
	
* A list of all blueprints as off the initial connection. Won't include new blueprints from research.

	`blueprints`
	
* A quick helper to show you all your inventory on the console. Javascript console.log won't show the full structure of the json data by default, so it has to be collapsed to display it all at once easily.

	`inventory()`
	`
	
* When you refit a structure or ship and remove only some of a blueprint, the related facilities are disabled and you have to pick which one to delete.

	`
	client.request('api', 'delete', 204, '/facilities/106e8fac-fde8-11e4-898a-6003089d765e').then(logit).fail(logit)
	`
	
* After you delete the facilities, make another call to get the system to reenable the remaining facilities.

	`
	client.request('api', 'post', 200, '/facilities', { container_id: '08569710-fde8-11e4-af81-358649381d17' }).then(logit).fail(logit)
	`
	`

	
