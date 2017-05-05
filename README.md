# Buildpack Standard Library

This repo contains a standard library for use within Heroku buildpacks.

It allows for unified output methods, some common buildpack utilities, and facilitates metrics logging.

## Usage

In your buildpack, add the following line (towards the top):

```bash
source /dev/stdin <<< "$(curl -s --retry 3 https://lang-common.s3.amazonaws.com/buildpack-stdlib/latest/stdlib.sh)"
```

Or, if you want to pin to a specific release:

```bash
source /dev/stdin <<< "$(curl -s --retry 3 https://lang-common.s3.amazonaws.com/buildpack-stdlib/v4/stdlib.sh)"
```

Or, if you are going to run the code multiple times in your source (e.g. in a `utils` file that gets sourced multiple times):

```bash
if [[ ! -f  /tmp/stdlib.sh ]]; then
  curl --retry 3 -s https://lang-common.s3.amazonaws.com/buildpack-stdlib/v4/stdlib.sh > /tmp/stdlib.sh
fi
source /tmp/stdlib.sh
```

We recommend pinning to a specific release, for stability reasons.

------------------------

 This will make the following functions available:

**Metrics**:

- `nowms`, which returns the current time in millesconds.
- `mtime`, which measures time elapsed for a specific build step.
- `mcount`, which logs a count for a specific build step.
- `mmeasure`, which logs a measure for specific build step.
- `munique`, which logs a unique measurement build step.
- `mcount_exit`, which logs an exit event and exits 1.

**Standard output (subject to change)**:

- `puts_step`, which outputs a build step in a standardized format.
- `puts_error`, which outputs a build error in a standarized format.
- `puts_warn`, which outputs a build warning in a standardized format.

**Buildpack utilities (subject to change)**:

- `set_env`, which writes an environment variable to a profile and export script (for multi-buildpack support).
- `set_default_env`, which writes a default environment variable to a profile and export script (for multi-buildpack support).
- `un_set_env`, which unsets a user-provided environment variable via profile script.
- `sub_env`, which launches a subshell with user-provided config.
- `export_env`, which exports user-provided config into the current shell.


*Please see the contents of [stdlib.sh](https://github.com/heroku/buildpack-stdlib/blob/master/stdlib.sh) for more usage details (including required environment variables).*

✨🍰✨


--------------------------

## Deploying to S3

- First, get pip installed (for Python).
- Then, install pipenv (`$ pip install pipenv`).
- `$ pipenv install`
- `$ pipenv run python upload.py v42 --latest`

Make sure you have `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` set.