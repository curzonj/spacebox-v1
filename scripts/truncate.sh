#!/usr/bin/env bash

rm dump.rdb
echo 'truncate space_objects, solar_systems, wormholes, inventories, facilities, jobs, items, blueprints, blueprint_perms' | psql -e spacebox

