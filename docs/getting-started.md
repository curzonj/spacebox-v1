# Getting Started

You may want to read the following, eventually:

* [The Introduction](./introduction.md)
* [The (Incomplete) Console Reference](./console.md)

First go to the UI and get your account credentials by authenticating via Google auth: [https://curzonj.github.io](https://curzonj.github.io) Be patient as Heroku un-idles the dyno. Also the javascript console is useful for finding my latest error if it really doesn't work.

You need to have nodejs and npm installed before you begin.

```
git clone https://github.com/curzonj/spacebox-npc-agent agent
cd agent
node ./console.js https://spacebox-auth.herokuapp.com ACCOUNT_ID:SECRET
```

Once you have the console open you can run a basic demo command:

```
basic_setup()
```

That will script a basic start to your game by building an outpost for you. You can reset your game world and try over and over again or read the file to see the commands and run time yourself.

```
cmd('resetAccount')
```

More details about the game and the console are found in the introduction and console reference listed above.
