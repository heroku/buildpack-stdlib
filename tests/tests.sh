#!/usr/bin/awk BEGIN{a=ARGV[1];sub(/[a-z_.]+$/,"bats/bin/bats",a);system(a"\t"ARGV[1])}
# ^^ Crazy hack to get relative paths to work w/ shebangs.

source stdlib.sh


setup() {
  export PROFILE_PATH=$(mktemp)
  export EXPORT_PATH=$(mktemp)
}

teardown() {
    unset PROFILE_PATH
    unset EXPORT_PATH
}

@test "output of puts-step" {
    run puts-step hello
    [ "$status" -eq 0 ]
    [ "$output" = "\e[1m\e[36m=== hello\e[0m" ]
}

@test "output of puts-error" {
    run puts-error hello
    [ "$status" -eq 0 ]
    [ "$output" = "\e[1m\e[31m=!= hello\e[0m" ]
}


@test "output of puts-warn" {
    run puts-warn hello
    [ "$status" -eq 0 ]
    [ "$output" = "\e[1m\e[33m=!= hello\e[0m" ]
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


@test "results of set-default-env" {

  set-default-env hello world

  result1="$(cat $PROFILE_PATH)"
  result2="$(cat $EXPORT_PATH)"

  [ "$result1" = 'export hello=${hello:-world}' ]
  [ "$result1" = 'export hello=${hello:-world}' ]
}


