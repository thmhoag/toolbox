#!/usr/bin/env bash

# always fail script if a cmd fails
set -eo pipefail

# required commands
command -v docker >/dev/null 2>&1 || { echo "docker is required but not installed, aborting..." >&2; exit 1; }

# make sure we are not already running
if [ ! -n $(docker ps -a --format '{{ .Names }}' | grep -oE toolbox) ]; then
	echo "toolbox already exists!" >&2;
	exit 1;
fi

docker run --rm -it \
	$@ \
	--hostname toolbox \
	--name toolbox \
	thmhoag/toolbox:latest