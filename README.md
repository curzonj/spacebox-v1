Spacebox is designed as an MMO to be hosted on servers. This is a repo to help you get all the different components downloaded and running together to work against locally.

## Getting Started

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

Ask Jordan for creds and the url to the staging instance and you can connect the
agent script to that instance and then you can start customizing your agent.

## Example

```
bundle install
ruby script/test.rb
```

```
cd client
npm install
forego run node ai.js
```
