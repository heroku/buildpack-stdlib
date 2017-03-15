# Buildpack Standard Library

This repo contains a standard library for use within Heroku buildpacks. 

It allows for unified output methods, some common buildpack utilities, and facilitates metrics logging. 

## Usage

In your buildpack, run the following command (towards the top):

    $ curl -s https://raw.githubusercontent.com/heroku/buildpack-stdlib/master/stdlib.sh > /tmp/stdlib.sh && source /tmp/stdlib.sh

**Note:** this URL will change to S3 once a bucket is provisioned. 

------------------------

 This will make the following functions available: 
 
 Standard output:
 
- `puts-line`, which outputs a line in a standardized format.
- `puts-step`, which outputs a build step in a standardized format.
- `puts-error`, which outputs a build error in a standarized format. 
- `puts-warn`, which outputs a build warning in a standardized format. 

Buildpack utilities:

- `set-env`, which writes an environment variable to a profile and export script (for multi-buildpack support). 
- `set-default-env`, which writes a default environment variable to a profile and export script (for multi-buildpack support). 
- `un-set-env`, which unsets a user-provided environment variable via profile script. 
- `sub-env`, which launches a subshell with user-provided config.

Metrics:

- `nowms`, which returns the current time in millesconds. 
- `mtime`, which measures time elapsed for a specific build step.
- `mcount`, which logs a count for a specific build step. 
- `mmeasure`, which logs a measure for specific build step. 
- `munique`, which logs a unique measurement build step. 
- `mcount-exit`, which logs an exit event and exists 1. 

✨🍰✨
