#!/usr/bin/env bats

source stdlib.sh


setup() {
  export PROFILE_PATH=$(mktemp)
  export EXPORT_PATH=$(mktemp)
  export BUILDPACK_LOG_FILE=$(mktemp)
  export BPLOG_PREFIX='tests'
}

teardown() {
    unset PROFILE_PATH
    unset EXPORT_PATH
}

@test "output of puts-step" {
    run puts-step hello
    [ "$status" -eq 0 ]
    [[ "$output" == *"=== hello"* ]]
}

@test "output of puts-error" {
    run puts-error hello
    [ "$status" -eq 0 ]
    [[ "$output" == *"=!= hello"* ]]
}


@test "output of puts-warn" {
    run puts-warn hello
    [ "$status" -eq 0 ]
    [[ "$output" == *"=!= hello"* ]]
}

@test "results of set-env" {

  set-env hello world

  result1="$(cat $PROFILE_PATH)"
  result2="$(cat $EXPORT_PATH)"

  [ "$result1" = "export hello=world" ]
  [ "$result2" = "export hello=world" ]
}

@test "results of set-env" {

  set-env hello world

  result1="$(cat $PROFILE_PATH)"
  result2="$(cat $EXPORT_PATH)"

  [ "$result1" = "export hello=world" ]
  [ "$result2" = "export hello=world" ]
}

@test "results of un-set-env" {

  un-set-env hello

  result="$(cat $PROFILE_PATH)"

  [ "$result" = "unset hello" ]
}

@test "results of set-default-env" {

  set-default-env hello world

  result1="$(cat $PROFILE_PATH)" 
  result2="$(cat $EXPORT_PATH)"

  [ "$result1" = 'export hello=${hello:-world}' ]
  [ "$result1" = 'export hello=${hello:-world}' ]
}

@test "nowms somewhat accurate" {
  result=$(nowms | cut -c1-5)
  now=$(date +%s%3N | cut -c1-5)

  [ "$now" = "$result" ]
}

@test "bplog functionality" {
  run bplog test
  result=$(cat $BUILDPACK_LOG_FILE)
  
  [ "$result" = 'msg="test"' ]
}