# Buildpack Indented line.
puts-line() {
  echo "       $@"
}

# Buildpack Steps.
puts-step() {
  echo "-----> $@"
}

# Buildpack Warnings.
puts-warn() {
  echo " !     $@"
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
