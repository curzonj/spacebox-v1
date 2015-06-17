# Getting Started

You may want to read the following, eventually:

* [The Introduction](./introduction.md)
* [The (Incomplete) Console Reference](./console.md)

First go to the UI and get your account credentials by authenticating via Google auth: [https://curzonj.github.io](https://curzonj.github.io) Be patient as Heroku un-idles the dyno. Also the javascript console is useful for finding my latest error if it really doesn't work.

You need to have nodejs, npm, and either foreman or forego installed before you begin.

```
git clone https://github.com/curzonj/spacebox-npc-agent agent
cd agent
cp sample.env heroku.env
# Edit heroku.env with your account credentials
foreman run -e heroku.env ./tests/construction.js
```

You should see a bunch of logs about building a Space Crate, launching it, and installing a factory in it. To play the game interactively, you can use the console.

```
foreman run -e heroku.env ./console.js
```

Once you have the console open you can see what objects in space and objects in inventory the tests script left behind for you.

```
console.log(world)
client.request('api', 'GET', 200, '/inventory').then(logit).fail(logit)
```

You can also reset your account spawn your seed ship again if you like:

```
cmd('resetAccount')
cmd('spawnStarter')
```

This spawns a seed ship with an asteroid miner, factory, and research lab. Currently the asteroid miner produces ore without actually doing anything because there are no asteroids to mine specifically.

What can you do with your seed ship? Look at the agent/tests/*.js files for ideas and examples.

More details about the game and the console are found in the introduction and console reference listed above.
