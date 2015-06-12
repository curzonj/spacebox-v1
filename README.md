Spacebox is designed as an MMO to be hosted on servers. This is a repo to help you get all the different components downloaded and running together to work against locally.

## Playing the game

* [Getting Started](./docs/getting-started.md)
* [The Introduction](./docs/introduction.md)
* [The (Incomplete) Console Reference](./docs/console.md)

## Development (Incomplete)

### Graylog

Graylog is for analyizing the game server while you develop.

```
cp .env.graylog.sample .env.graylog
docker-compose up -d
```

1. You log into your graylog server at port 9000 on your boot2docker ip.
2. Go to System->Inputs
3. Add a GELF UDP input on port 12201
3. Add a Raw TCP input on port 5555

## Development (outdated)

You'll need nodejs either forman or [forego](https://github.com/ddollar/forego) installed.

```
cp env.sample .env
git submodule init
git submodule update
for i in 3dsim auth build inventory tech; do pushd $i; npm install; popd; done
forego start
```

In another terminal
```
cd agents
npm install
forego start node arena.js
```
