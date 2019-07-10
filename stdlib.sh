#!/usr/bin/env bash

# Buildpack defaults
# ---------------

export BUILDPACK_LOG_FILE="${BUILDPACK_LOG_FILE:-/dev/null}"

# throw an error with an error message
error_exit() {
    echo "${1:-"Unknown Error"}" 1>&2
    exit 1
}

# Standard Output
# ---------------

# Buildpack Steps.
puts_step() {
  if [[ "$*" == "-" ]]; then
    read -r output
  else
    output=$*
  fi
  echo -e "\\e[1m\\e[36m=== $output\\e[0m"
  unset output
}

# Buildpack Error.
puts_error() {
  if [[ "$*" == "-" ]]; then
    read -r output
  else
    output=$*
  fi
  echo -e "\\e[1m\\e[31m=!= $output\\e[0m"
}

# Buildpack Warning.
puts_warn() {
  if [[ "$*" == "-" ]]; then
    read -r output
  else
    output=$*
  fi
  echo -e "\\e[1m\\e[33m=!= $output\\e[0m"
}

# Is verbose set?
is_verbose() {
  if [[ -n $BUILDPACK_VERBOSE ]]; then
    return 0
  else
    return 1
  fi
}

# Buildpack Verbose.
puts_verbose() {
  if is_verbose; then
    if [[ "$*" == "-" ]]; then
      read -r output
    else
      output=$*
    fi
    echo "$output"
    unset output
  fi
}

# Key Value Store Utility
# -------------------

# This is a utility module that allows you to create a file that serves
# as a key-value store that can be persisted to disk.
#
# It works around using lines formatted like:
# 
# key=value
#
# and using grep when searching for keys to find the last entry. This 
# allows an existing key to be overwritten.
#
# This is inspired by the "world's simplest database" in Ch 3 of
# Designing Data-Intensive Applications https://dataintensive.net/

# Ensure that the file that we would like to persist this store to
# exists. Also handles creating the containing directory if it doesn't
# exist yet. 
#
# Will not overwrite the store if it already exists
# Usage: kv_create file
kv_create() {
  local f=$1
  mkdir -p "$(dirname "$f")"
  touch "$f"
}

# Delete all keys and values from the store
# Usage: kv_clear file
kv_clear() {
  local f=$1
  echo "" > "$f"
}

kv_validate_key() {
	[[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$  ]]
}

# Set value for a key
# Usage: kv_set file key value
kv_set() {
  local f value

  if (( $# != 3 )); then
    error_exit "Expected 3 arguments to kv_set, received $#"
  fi

  kv_validate_key "$2" || error_exit "invalid param to kv_set '$2'"

  f=$1
  # before we save the string:
  # - change any newlines into spaces
  # - trim off any spaces from the start or end of the string
  #   otherwise if you set a value without quotes: kv_set "$store" foo bar
  #   it will be saved with a '\n' and you will get "bar " in return
  value="$(echo "$3" | tr '\n' ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  if [[ -w $f ]]; then
    echo "$2=$value" >> "$f"
  fi
}

# Retrieve value for a key. Will return an empty string if the key is
# not present
# Usage: kv_get file key
kv_get() {
  if (( $# != 2 )); then
    error_exit "Expected 2 arguments to kv_get, received $#"
  fi

  local f=$1
  if [[ -r $f ]]; then
    grep "^$2=" "$f" | sed -e "s/^$2=//" | tail -n 1
  fi
}

# Retrive the value for a key, but wrap it in quotes if the value contains spaces
# This is expected to be mostly used internally
# Usage: kv_get_escaped file key
kv_get_escaped() {
  local value
  # retrieve the value and escape any quotes with backslashes
  value=$(kv_get "$1" "$2" |  sed 's/"/\\"/g')
  if [[ $value =~ [[:space:]]+ ]]; then
    echo "\"$value\""
  else
    echo "$value"
  fi
}

# List out each of the keys in the store
# Usage: kv_keys file
kv_keys() {
  local f=$1
  local keys=()

  if [[ -f $f ]]; then
    # Iterate over each line, splitting on the '=' character
    #
    # The || [[ -n "$key" ]] statement addresses an issue with reading the last line
    # of a file when there is no newline at the end. This will not happen if the file
    # is created with this module, but can happen if it is written by hand.
    # See: https://stackoverflow.com/questions/12916352/shell-script-read-missing-last-line
    while IFS="=" read -r key value || [[ -n "$key" ]]; do
      # if there are any empty lines in the store, skip them
      if [[ -n $key ]]; then
        keys+=("$key")
      fi
    done < "$f"

    echo "${keys[@]}" | tr ' ' '\n' | sort -u
  fi
}

# Log out each of the keys and values in the store, one per line
# Usage: kv_list file
kv_list() {
  local f=$1

  kv_keys "$f" | tr ' ' '\n' | while read -r key; do
    if [[ -n $key ]]; then
      echo "$key=$(kv_get_escaped "$f" "$key")"
    fi
  done
}

# Buildpack Utilities
# -------------------

# Usage: $ set-env key value
# NOTICE: Expects PROFILE_PATH & EXPORT_PATH to be set!
set_env() {
  # TODO: automatically create profile path directory if it doesn't exist.
  echo "export $1=$2" >> "$PROFILE_PATH"
  echo "export $1=$2" >> "$EXPORT_PATH"
}

# Usage: $ set-default-env key value
# NOTICE: Expects PROFILE_PATH & EXPORT_PATH to be set!
set_default_env() {
  echo "export $1=\${$1:-$2}" >> "$PROFILE_PATH"
  echo "export $1=\${$1:-$2}" >> "$EXPORT_PATH"
}

# Usage: $ un-set-env key
# NOTICE: Expects PROFILE_PATH to be set!
un_set_env() {
  echo "unset $1" >> "$PROFILE_PATH"
}

# Usage: $ _env-blacklist pattern
# Outputs a regex of default blacklist env vars.
_env_blacklist() {
  local regex=${1:-''}
  if [ -n "$regex" ]; then
    regex="|$regex"
  fi
  echo "^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH$regex)$"
}

# Usage: $ export-env ENV_DIR WHITELIST BLACKLIST
# Exports the environment variables defined in the given directory.
export_env() {
  local env_dir=${1:-$ENV_DIR}
  local whitelist=${2:-''}
  local blacklist
  blacklist="$(_env_blacklist "$3")"
  if [ -d "$env_dir" ]; then
    # Environment variable names won't contain characters affected by:
    # shellcheck disable=SC2045
    for e in $(ls "$env_dir"); do
      echo "$e" | grep -E "$whitelist" | grep -qvE "$blacklist" &&
      export "$e=$(cat "$env_dir/$e")"
      :
    done
  fi
}

# Usage: $ sub-env command
# Runs a subshell of specified command with user-provided config.
# NOTICE: Expects ENV_DIR to be set. WHITELIST & BLACKLIST are optional.
# Examples:
#    WHITELIST=${2:-''}
#    BLACKLIST=${3:-'^(GIT_DIR|PYTHONHOME|LD_LIBRARY_PATH|LIBRARY_PATH|PATH)$'}
sub_env() {
  (
    # TODO: Fix https://github.com/heroku/buildpack-stdlib/issues/37
    # shellcheck disable=SC2153
    export_env "$ENV_DIR" "$WHITELIST" "$BLACKLIST"

    "$@"
  )
}

# Logging
# -------

# Notice: These functions expect BPLOG_PREFIX and BUILDPACK_LOG_FILE to be defined (BUILDPACK_LOG_FILE can point to /dev/null if not provided by the buildpack).
# Example: BUILDPACK_LOG_FILE=${BUILDPACK_LOG_FILE:-/dev/null}; BPLOG_PREFIX="buildpack.go"

# Returns now, in milleseconds. Useful for logging.
# Example: $ let start=$(nowms); sleep 30; mtime "glide.install.time" "${start}"
nowms() {
  date +%s%3N
}

# Log arbitrary data to the logfile (e.g. a packaging file).
# Usage: $ bplog "$(<${vendorJSON})
bplog() {
  echo -n "${@}" | awk 'BEGIN {printf "msg=\""; f="%s"} {gsub(/"/, "\\\"", $0); printf f, $0} {if (NR == 1) f="\\n%s" } END { print "\"" }' >> "${BUILDPACK_LOG_FILE}"
}

# Measures time elapsed for a specific build step.
# Usage: $ let start=$(nowms); mtime "glide.install.time" "${start}"
# https://github.com/heroku/engineering-docs/blob/master/guides/logs-as-data.md#distributions-measure
mtime() {
  local key="${BPLOG_PREFIX}.${1}"
  local start="${2}"
  local end="${3:-$(nowms)}"
  echo "${key} ${start} ${end}" | awk '{ printf "measure#%s=%.3f\n", $1, ($3 - $2)/1000 }' >> "${BUILDPACK_LOG_FILE}"
}

# Logs a count for a specific built step.
# Usage: $ mcount "tool.govendor"
# https://github.com/heroku/engineering-docs/blob/master/guides/logs-as-data.md#counting-count
mcount() {
  local k="${BPLOG_PREFIX}.${1}"
  local v="${2:-1}"
  echo "count#${k}=${v}" >> "${BUILDPACK_LOG_FILE}"
}

# Logs a measure for a specific build step.
# Usage: $ mmeasure "tool.installed_dependencies" 42
# https://github.com/heroku/engineering-docs/blob/master/guides/logs-as-data.md#distributions-measure
mmeasure() {
  local k="${BPLOG_PREFIX}.${1}"
  local v="${2}"
  echo "measure#${k}=${v}" >> "${BUILDPACK_LOG_FILE}"
}

# Logs a unuique measurement build step.
# Usage: $ munique "versions.count" 2.7.13
# https://github.com/heroku/engineering-docs/blob/master/guides/logs-as-data.md#uniques-unique
munique() {
  local k="${BPLOG_PREFIX}.${1}"
  local v="${2}"
  echo "unique#${k}=${v}" >> "${BUILDPACK_LOG_FILE}"
}

# Measures when an exit path to the buildpack is reached, given a name, then exits 1.
# Usage: $ mcount-exi "binExists"
mcount_exit() {
  mcount "error.${1}"
  exit 1
}
