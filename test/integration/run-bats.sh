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
    if [[ $(machine ls -q | wc -l) -ne 0 ]]; then
        #quiet_run machine stop $(machine ls -q)
        quiet_run machine rm -f $(machine ls -q)
    fi
}

function machine() {
    export PATH="$PLUGIN_ROOT"/bin:$PATH
    "$MACHINE_BINARY" "$@"
}

function run_bats() {
    for bats_file in $(find "$1" -name \*.bats); do
        # BATS returns non-zero to indicate the tests have failed, we shouldn't
        # neccesarily bail in this case, so that's the reason for the e toggle.
        set +e
        echo "=> $bats_file"
        bats "$bats_file"
        if [[ $? -ne 0 ]]; then
            EXIT_STATUS=1
        fi
        set -e
        echo
        cleanup_machines
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

# Set defaults if variables are not defined
export MACHINE_BINARY=${MACHINE_BINARY:-"docker-machine"}

export DRIVER="parallels"
export BASE_TEST_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export PLUGIN_ROOT="$BASE_TEST_DIR/../.."
export NAME="bats-$DRIVER-test"
export MACHINE_STORAGE_PATH="/tmp/machine-bats-test-$DRIVER"
export BATS_LOG="$PLUGIN_ROOT/bats.log"

# This function gets used in the integration tests, so export it.
export -f machine

rm -f "$BATS_LOG"

run_bats "$BATS_FILE"

if [[ -d "$MACHINE_STORAGE_PATH" ]]; then
    rm -r "$MACHINE_STORAGE_PATH"
fi

set +e
pkill docker-machine
if [[ $? -gt 1 ]]; then
    EXIT_STATUS=1
fi
set -e

exit ${EXIT_STATUS}
