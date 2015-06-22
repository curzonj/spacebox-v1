#!/bin/bash

set -e
set -x

rm -f *.wtf-trace

./api/node_modules/swagger-tools/bin/swagger-tools validate -v api/docs/swagger.json

forego run ./scripts/truncate.sh
forego run node api/bin/load_blueprints.js
forego start
