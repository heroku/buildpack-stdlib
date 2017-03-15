# Standard Output
# ---------------

# Buildpack Indented line.
puts-line() {
  echo "$@"
}

# Buildpack Steps.
puts-step() {
  echo -e "\e[1m\e[36m=== $@\e[0m"
}

# Buildpack Error.
puts-error() {
  echo -e "\e[1m\e[31m=!= $@\e[0m"
}

# Buildpack Warning.
puts-warn() {
  echo -e "\e[1m\e[33m=!= $@\e[0m"
}


# Buildpack Utilities
# -------------------

# Usage: $ set-env key value
# NOTICE: Expects PROFILE_PATH & EXPORT_PATH to be set!
set-env() {
  echo "export $1=$2" >> $PROFILE_PATH
  echo "export $1=$2" >> $EXPORT_PATH
}

# Usage: $ set-default-env key value
# NOTICE: Expects PROFILE_PATH & EXPORT_PATH to be set!
set-default-env() {
  echo "export $1=\${$1:-$2}" >> $PROFILE_PATH
  echo "export $1=\${$1:-$2}" >> $EXPORT_PATH
}

# Usage: $ un-set-env key
# NOTICE: Expects PROFILE_PATH & EXPORT_PATH to be set!
un-set-env() {
  echo "unset $1" >> $PROFILE_PATH
}

# Usage: $ sub-env command
# Runs a subshell with user-provided config
# NOTICE: Expects a WHITELIST & BLACKLIST to be set! Examples:
#    WHITELIST=${2:-''}
#    BLACKLIST=${3:-'^(GIT_DIR|PYTHONHOME|LD_LIBRARY_PATH|LIBRARY_PATH|PATH)$'}
sub-env() {
  (
    if [ -d "$ENV_DIR" ]; then
      for e in $(ls $ENV_DIR); do
        echo "$e" | grep -E "$WHITELIST" | grep -qvE "$BLACKLIST" &&
        export "$e=$(cat $ENV_DIR/$e)"
        :
      done
    fi

    $1

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
  echo -n ${@} | awk 'BEGIN {printf "msg=\""; f="%s"} {gsub(/"/, "\\\"", $0); printf f, $0} {if (NR == 1) f="\\n%s" } END { print "\"" }' >> ${BUILDPACK_LOG_FILE}
}

# Measures time elapsed for a specific build step. 
# Usage: $ let start=$(nowms); mtime "glide.install.time" "${start}"
# https://github.com/heroku/engineering-docs/blob/master/guides/logs-as-data.md#distributions-measure
mtime() {
    local key="${BPLOG_PREFIX}.${1}"
    local start="${2}"
    local end="${3:-$(nowms)}"
    echo "${key} ${start} ${end}" | awk '{ printf "measure#%s=%.3f\n", $1, ($3 - $2)/1000 }' >> ${BUILDPACK_LOG_FILE}
}

# Logs a count for a specific built step. 
# Usage: $ mcount "tool.govendor"
# https://github.com/heroku/engineering-docs/blob/master/guides/logs-as-data.md#counting-count
mcount() {
    local k=”${BPLOG_PREFIX}.${1}”
    local v=”${2:1}”
    echo “count#${k}=${v}” >> ${BUILDPACK_LOG_FILE}
}

# Logs a measure for a specific build step. 
# Usage: $ mmeasure "tool.installed_dependencies" 42
# https://github.com/heroku/engineering-docs/blob/master/guides/logs-as-data.md#distributions-measure
mmeasure() {
    local k=”${BPLOG_PREFIX}.${1}”
    local v=”${2}”
    echo “measure#${k}=${v}” >> ${BUILDPACK_LOG_FILE}
}

# Logs a unuique measurement build step. 
# Usage: $ munique "versions.count" 2.7.13
# https://github.com/heroku/engineering-docs/blob/master/guides/logs-as-data.md#uniques-unique
munique() {
    local k="${BPLOG_PREFIX}.${1}"
    local v=”${2}”
    echo "unique#${k}=${v}" >> ${BUILDPACK_LOG_FILE}
}

# Measures when an exit path to the buildpack is reached, given a name, then exits 1. 
# Usage: $ mcount-exi "binExists"
mcount-exit() {
    mcount "error.${1}"
    exit 1
}
