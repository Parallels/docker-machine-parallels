#!/usr/bin/env bats

load ${BASE_TEST_DIR}/helpers.bash

use_disposable_machine

@test "$DRIVER: create with custom shared folders" {
  run machine create -d $DRIVER --parallels-share-folder ~/Documents --parallels-share-folder /Library/Application\ Support $NAME
}

@test "$DRIVER: shared folder with a tilda (~) is mounted properly" {
  run machine ssh $NAME -- "mount -t prl_fs | awk -F ' on | type ' '{ print \$2 }'"
  echo ${output}
  [ "$status" -eq 0  ]
  [[ ${output} == *"/Users"*"/Documents"* ]]
}

@test "$DRIVER: shared folder with a space is mounted properly" {
  run machine ssh $NAME -- "mount -t prl_fs | awk -F ' on | type ' '{ print \$2 }'"
  echo ${output}
  [ "$status" -eq 0  ]
  [[ ${output} == *"/Library/Application Support"* ]]
}
