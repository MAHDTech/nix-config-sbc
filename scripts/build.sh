#!/usr/bin/env bash

clear
set -euo pipefail

#########################
# Variables
#########################

export TMPDIR
export NIX_BUILD_CORES=1
export NIX_MAX_JOBS=1

ARGS=("${@}")

#########################
# Functions
#########################

function msg() {
	local LOG_LEVEL=$1
	local MSG=$2

	case $LOG_LEVEL in
	"INFO")
		echo -e "\033[32m[${LOG_LEVEL}]\033[0m ${MSG}"
		;;
	"WARN")
		echo -e "\033[33m[${LOG_LEVEL}]\033[0m ${MSG}"
		;;
	"ERROR")
		echo -e "\033[31m[${LOG_LEVEL}]\033[0m ${MSG}"
		;;
	*)
		echo -e "\033[37m[${LOG_LEVEL}]\033[0m ${MSG}"
		;;
	esac

	return 0
}

#########################
# Checks
#########################

if [ -z "${ARGS[*]}" ]; then
	msg "ERROR" "No arguments provided"
	exit 1
fi

#########################
# Main
#########################

msg "INFO" "Staging changes..."
git add --all

msg "INFO" "Elevating privileges..."
sudo -v

msg "INFO" "Starting memory-optimized build..."

msg "INFO" "Compacting memory..."
echo 1 | sudo tee /proc/sys/vm/compact_memory >/dev/null
msg "INFO" "Memory compacted"

# Create a temporary directory for the build
TMPDIR=$(mktemp -d)

# Clean up before build unless disabled
if [[ ${DISABLE_GARBAGE_COLLECTION:-EMPTY} != "EMPTY" ]]; then
	msg "INFO" "Skipping garbage collection due to DISABLE_GARBAGE_COLLECTION..."
else
	msg "INFO" "Cleaning up..."
	nix-collect-garbage -d
	msg "INFO" "Garbage collection complete"
fi

# Build with memory constraints
msg "INFO" "Building with memory optimizations..."
nix build \
	--cores 1 \
	--max-jobs 1 \
	--option sandbox true \
	--show-trace \
	-L \
	--verbose \
	--system aarch64-linux \
	"${ARGS[@]}"
