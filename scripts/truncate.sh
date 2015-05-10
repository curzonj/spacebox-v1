#!/usr/bin/env bash

echo 'truncate space_objects, solar_systems, wormholes' | psql -e spacebox-spodb
echo 'truncate solar_systems' | psql -e spacebox-map
echo 'truncate inventories;' | psql -e spacebox-inventory
echo 'truncate facilities, jobs;' | psql -e spacebox-build



