# Buildpack Standard Library

This repo contains a standard library for use within Heroku buildpacks. 

It allows for unified output methods, some common buildpack utilities, and facilitates metrics logging. 

## Usage

In your buildpack, run the following command (towards the top):

    $ curl -s https://lang-common.s3.amazonaws.com/buildpack-stdlib/latest/stdlib.sh > /tmp/stdlib.sh && source /tmp/stdlib.sh
    
Or, if you want to pin to a specific release:

    $ curl -s https://lang-common.s3.amazonaws.com/buildpack-stdlib/v1/stdlib.sh > /tmp/stdlib.sh && source /tmp/stdlib.sh

------------------------

 This will make the following functions available: 
 
**Metrics**:

- `nowms`, which returns the current time in millesconds. 
- `mtime`, which measures time elapsed for a specific build step.
- `mcount`, which logs a count for a specific build step. 
- `mmeasure`, which logs a measure for specific build step. 
- `munique`, which logs a unique measurement build step. 
- `mcount-exit`, which logs an exit event and exits 1. 

**Standard output (subject to change)**:
 
- `puts-step`, which outputs a build step in a standardized format.
- `puts-error`, which outputs a build error in a standarized format. 
- `puts-warn`, which outputs a build warning in a standardized format. 

**Buildpack utilities (subject to change)**:

- `set-env`, which writes an environment variable to a profile and export script (for multi-buildpack support). 
- `set-default-env`, which writes a default environment variable to a profile and export script (for multi-buildpack support). 
- `un-set-env`, which unsets a user-provided environment variable via profile script. 
- `sub-env`, which launches a subshell with user-provided config.


*Please see the contents of [stdlib.sh](https://github.com/heroku/buildpack-stdlib/blob/master/stdlib.sh) for more usage details (including required environment variables).*

✨🍰✨
