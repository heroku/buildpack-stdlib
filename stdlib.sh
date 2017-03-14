# Buildpack Indented line.
puts-line() {
  echo "$@"
}

/bin/echo -e "\e[1;31mThis is red text\e[0m"

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
