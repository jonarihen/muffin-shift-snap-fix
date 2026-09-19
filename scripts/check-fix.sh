#!/usr/bin/env bash
set -euo pipefail

library=/usr/lib/x86_64-linux-gnu/libmuffin.so.0.0.0
expected_sha256=c88a6cf4e234935cb5637655bf6ce2aaf7cd9a561e12232506ea9ffdd139597c
actual_sha256=$(sha256sum "$library" | awk '{print $1}')

if [[ "$actual_sha256" != "$expected_sha256" ]]; then
  printf 'FAIL: %s differs from the documented patched build.\n' "$library" >&2
  exit 1
fi

if ! apt-mark showhold | grep -Fxq libmuffin0; then
  printf 'FAIL: libmuffin0 is not held, so a Mint update can replace the fix.\n' >&2
  exit 1
fi

if [[ $(gsettings get org.cinnamon.muffin edge-tiling) != false ]]; then
  printf 'FAIL: Cinnamon edge tiling is enabled.\n' >&2
  exit 1
fi

printf 'OK: patched libmuffin0 is installed, held, and Cinnamon edge tiling is disabled.\n'
