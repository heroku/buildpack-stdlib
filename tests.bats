#!/usr/bin/env bats

source stdlib.sh


setup() {
  # The Basics.
  export PROFILE_PATH=$(mktemp)
  export EXPORT_PATH=$(mktemp)
  export BUILDPACK_LOG_FILE=$(mktemp)
  export BPLOG_PREFIX='tests'

  # User Environment Variables.
  mkdir -p $BATS_TMPDIR/env/
  echo "WORLD" > $BATS_TMPDIR/env/HELLO
  export ENV_DIR="$BATS_TMPDIR/env/"
}

teardown() {
  unset PROFILE_PATH
  unset EXPORT_PATH
  unset BUILDPACK_LOG_FILE
  unset BPLOG_PREFIX
  unset ENV_DIR
}

@test "output of puts_step" {
  run puts_step hello
  [ "$status" -eq 0 ]
  [[ "$output" == *"=== hello"* ]] || false
}

@test "piped input of puts_step" {
  output=$(echo 'hello' | puts_step -)
  [[ "$output" == *"=== hello"* ]] || false
}

@test "output of puts_error" {
  run puts_error hello
  [ "$status" -eq 0 ]
  [[ "$output" == *"=!= hello"* ]] || false
}

@test "piped input of puts_error" {
  output=$(echo 'hello' | puts_error -)
  [[ "$output" == *"=!= hello"* ]] || false
}

@test "output of puts_warn" {
  run puts_warn hello
  [ "$status" -eq 0 ]
  [[ "$output" == *"=!= hello"* ]] || false
}

@test "piped input of puts_warn" {
  output=$(echo 'hello' | puts_warn -)
  [[ "$output" == *"=!= hello"* ]] || false
}

@test "output of puts_verbose" {
  run puts_verbose hello
  [ "$status" -eq 0 ]
  [ "$output" == "" ]

  BUILDPACK_VERBOSE=true

  run puts_verbose hello
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello"* ]] || false
}

@test "piped input of puts_verbose" {
  output=$(echo 'hello' | puts_verbose -)
  [ "$output" == "" ]

  BUILDPACK_VERBOSE=true

  output=$(echo 'hello' | puts_verbose -)
  [[ "$output" == *"hello"* ]]
}

@test "results of set_env" {
  set_env hello world

  result1="$(cat $PROFILE_PATH)"
  result2="$(cat $EXPORT_PATH)"

  [ "$result1" = "export hello=world" ]
  [ "$result2" = "export hello=world" ]
}

@test "results of set_env" {
  set_env hello world

  result1="$(cat $PROFILE_PATH)"
  result2="$(cat $EXPORT_PATH)"

  [ "$result1" = "export hello=world" ]
  [ "$result2" = "export hello=world" ]
}

@test "results of un_set_env" {
  un_set_env hello

  result="$(cat $PROFILE_PATH)"

  [ "$result" = "unset hello" ]
}

@test "results of set_default_env" {
  set_default_env hello world

  result1="$(cat $PROFILE_PATH)"
  result2="$(cat $EXPORT_PATH)"

  [ "$result1" = 'export hello=${hello:-world}' ]
  [ "$result2" = 'export hello=${hello:-world}' ]
}

@test "nowms somewhat accurate" {
  result=$(nowms | cut -c1-5)
  now=$(date +%s%3N | cut -c1-5)

  [ "$now" = "$result" ]
}

@test "bplog functionality" {
  bplog test
  result=$(cat $BUILDPACK_LOG_FILE)

  [ "$result" = 'msg="test"' ]
}

@test "mtime functionality" {
  mtime "something" $(nowms)
  result=$(cat $BUILDPACK_LOG_FILE | cut -c1-24)

  [ "$result" = "measure#tests.something=" ]
}

@test "mcount functionality" {
  mcount "something"

  result=$(cat $BUILDPACK_LOG_FILE)

  [ "$result" = "count#tests.something=1" ]
}

@test "mmeasure functionality" {
  mmeasure "something" 42

  result=$(cat $BUILDPACK_LOG_FILE)

  [ "$result" = "measure#tests.something=42" ]
}

@test "munique functionality" {
  munique "something" 42

  result=$(cat $BUILDPACK_LOG_FILE)

  [ "$result" = "unique#tests.something=42" ]
}

@test "mcount_exit functionality" {
  run mcount_exit "something"

  [ "$status" -eq 1 ]
}

@test "export_env working properly" {
  export_env

  [ "$HELLO" = "WORLD" ]
}

@test "sub_env working properly" {
  run sub_env env

  [[ "$output" == *"HELLO=WORLD"* ]] || false
}
