#!/bin/bash

set -e

TMP=$(mktemp)

curl -fsSL \
  https://raw.githubusercontent.com/MitrichevGeorge/bash-papermc/main/install-main.sh \
  -o "$TMP"

chmod +x "$TMP"

"$TMP" "$@"

rm -f "$TMP"