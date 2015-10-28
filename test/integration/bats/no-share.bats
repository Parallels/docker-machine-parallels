#!/usr/bin/env bats

load ${BASE_TEST_DIR}/helpers.bash

@test "$DRIVER: create with disabled sharing" {
  run machine create -d $DRIVER --parallels-no-share $NAME
}

@test "$DRIVER: shared folder is not mounted mounted" {
  run machine ssh $NAME -- "mount | grep prl_fs"
  echo ${output}
  [ "$status" -eq 1  ]
}
