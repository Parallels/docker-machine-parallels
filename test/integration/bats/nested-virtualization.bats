#!/usr/bin/env bats

load ${BASE_TEST_DIR}/helpers.bash

use_disposable_machine

@test "$DRIVER: create with nested virtualization" {
  run machine create -d $DRIVER --parallels-nested-virtualization $NAME
}

@test "$DRIVER: nested virtualization is enabled" {
  run machine ssh $NAME -- "cat /proc/cpuinfo | grep vmx"
  [ "$status" -eq 0  ]
}
