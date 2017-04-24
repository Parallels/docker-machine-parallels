#!/bin/bash

set -e

# Wrapper script to run bats tests for "parallels" driver.
# Usage: ./run-bats.sh [subtest]

function quiet_run () {
    if [[ "$VERBOSE" == "1" ]]; then
        "$@"
    else
        "$@" &>/dev/null
    fi
}

function cleanup_machines() {
    for MACHINE_NAME in $(machine ls -q); do
        if [[ "$MACHINE_NAME" != "$SHARED_NAME" ]] || [[ "$1" == "ALL" ]]; then
            quiet_run machine rm -f $MACHINE_NAME
        fi
    done
}

function cleanup_store() {
    if [[ -d "$MACHINE_STORAGE_PATH" ]]; then
        rm -r "$MACHINE_STORAGE_PATH"
    fi
}

function machine() {
    "$MACHINE_BIN_NAME" "$@"
}

function run_bats() {
    for bats_file in $(find "$1" -name \*.bats); do
        echo "=> $bats_file"
        # BATS returns non-zero to indicate the tests have failed, we shouldn't
        # necessarily bail in this case, so that's the reason for the e toggle.
        set +e
        bats "$bats_file"
        if [[ $? -ne 0 ]]; then
            EXIT_STATUS=1
        fi
        set -e
        echo
        cleanup_machines "ALL"
    done
}

# Set this ourselves in case bats call fails
EXIT_STATUS=0
export BATS_FILE="$1"

if [[ -z "$BATS_FILE" ]]; then
    echo "You must specify a bats test to run."
    exit 1
fi

if [[ ! -e "$BATS_FILE" ]]; then
    echo "Requested bats file or directory not found: $BATS_FILE"
    exit 1
fi

export DRIVER="parallels"
export BASE_TEST_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PLUGIN_ROOT="$BASE_TEST_DIR/../.."
export MACHINE_STORAGE_PATH="/tmp/machine-bats-test-$DRIVER"
export MACHINE_BIN_NAME=docker-machine
export BATS_LOG="$PLUGIN_ROOT/bats.log"
export B2D_LOCATION=~/.docker/machine/cache/boot2docker.iso
export SHARED_NAME="bats-$DRIVER-test-shared-$(date +%s)"

# Local plugin binary (./bin/) takes precedence
export PATH="$PLUGIN_ROOT"/bin:$PATH

# This function gets used in the integration tests, so export it.
export -f machine

> "$BATS_LOG"

cleanup_machines "ALL"
cleanup_store

if [[ -f "$B2D_LOCATION" ]]; then
    if [[ "$B2D_CACHE" == "1" ]]; then
        mkdir -p "${MACHINE_STORAGE_PATH}/cache"
        cp $B2D_LOCATION "${MACHINE_STORAGE_PATH}/cache/boot2docker.iso"
    else
        echo "INFO: Run the tests with B2D_CACHE=1 to avoid downloading the boot2docker iso each time."
    fi
fi

run_bats "$BATS_FILE"

cleanup_machines "ALL"
cleanup_store

exit ${EXIT_STATUS}
