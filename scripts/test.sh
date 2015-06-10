#!/bin/bash

set -e
set -x

./scripts/truncate.sh

export DEBUG=psql,inv,3dsim:*,build:*,dao
export MYDEBUG=*

forego run node api/bin/load_blueprints.js

forego start
