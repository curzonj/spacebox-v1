#!/bin/bash

set -e
set -x

rm -f main-*.wtf-trace

forego run ./scripts/truncate.sh
forego run node api/bin/load_blueprints.js
forego start
