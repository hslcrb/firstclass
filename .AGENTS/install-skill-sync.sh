#!/bin/sh
set -eu
script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)
exec sh "$script_dir/skill-sync.sh" install "$@"
