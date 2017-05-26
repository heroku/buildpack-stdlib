# The Buildpack Standard Library

[![GitHub tag](https://img.shields.io/github/tag/heroku/buildpack-stdlib.svg)]()
[![Build Status](https://img.shields.io/travis/heroku/buildpack-stdlib/master.svg)](https://travis-ci.org/heroku/buildpack-stdlib)
[![Available](https://img.shields.io/website-up-down-green-red/http/lang-common.s3.amazonaws.com.svg?label=Deployment%20Available)]()


This repo contains a standard library for use within Heroku Buildpacks.

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

**Standard output**:

- `puts_step`, which outputs a build step in a standardized format.
- `puts_error`, which outputs a build error in a standarized format.
- `puts_warn`, which outputs a build warning in a standardized format.
- `puts_verbose`, which outputs a build step if the environment variable `BUILDPACK_VERBOSE` is set.
- `is_verbose`, which returns `0`/`1`, depending on if it's appropriate to use verbose output or not.

**Buildpack utilities**:

- `set_env`, which writes an environment variable to a profile and export script (for multi-buildpack support).
- `set_default_env`, which writes a default environment variable to a profile and export script (for multi-buildpack support).
- `un_set_env`, which unsets a user-provided environment variable via profile script.
- `sub_env`, which launches a subshell with user-provided config.
- `export_env`, which exports user-provided config into the current shell.

**Metrics (only available to Official Heroku Buildpacks)**:

- `nowms`, which returns the current time in millesconds.
- `mtime`, which measures time elapsed for a specific build step.
- `mcount`, which logs a count for a specific build step.
- `mmeasure`, which logs a measure for specific build step.
- `munique`, which logs a unique measurement build step.
- `mcount_exit`, which logs an exit event and exits 1.

*Please see the contents of [stdlib.sh](https://github.com/heroku/buildpack-stdlib/blob/master/stdlib.sh) for more usage details (including required environment variables).*

✨🍰✨


--------------------------

## Deploying to Amazon S3

Fetch the repo from GitHub:

- `$ git clone git@github.com:heroku/buildpack-stdlib.git`
- `$ cd buildpack-stdlib`

Upload the stdlib to Amazon S3:

- `$ git remote add heroku https://git.heroku.com/buildpack-stdlib.git`
- `$ git push heroku master`
- `$ heroku run python upload.py`

Notice the version number outputted, then tag it in Git and push that to GitHub:
- `$ git tag v42`
- `$ git push --tags`

Don't forget to update `HISTORY.txt`!
