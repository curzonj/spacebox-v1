#!/usr/bin/env bash

for i in 3dsim tech auth; do
        pushd $i
        git push heroku master
        popd
done
