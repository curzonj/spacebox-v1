#!/usr/bin/env bash

set -e
set -x

redis-cli -h $DOCKER_IP FLUSHDB
echo 'truncate space_objects, solar_systems, wormholes, containers, facilities, jobs, items, blueprints, blueprint_perms' | psql -e spacebox

