#!/usr/bin/env bash

# Enable error handling
set -eo pipefail

# Enable debugging
# set -x

# Ensure that RCON is enabled
if [[ "$RCON_ENABLED" != "true" ]]; then
  echo "RCON is disabled, exiting.."
  exit 1
fi

mcrcon \
  -H "127.0.0.1" \
  -P "${RCON_PORT}" \
  -p "${RCON_PASSWORD}" \
  "$@"