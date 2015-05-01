#!/usr/bin/env bash

echo 'truncate space_objects;' | psql -e spacebox-spodb
echo 'truncate inventories;' | psql -e spacebox-inventory
echo 'truncate facilities; truncate jobs;' | psql -e spacebox-build



