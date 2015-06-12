#!/bin/bash

set -e
set -x

forego run ./scripts/truncate.sh
forego run node api/bin/load_blueprints.js
forego start
