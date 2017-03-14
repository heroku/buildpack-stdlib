# buildpack-stdlib

A standard library for Heroku buildpacks.


## Usage

In your buildpack, run the following command (towards the top):

    $ curl -s https://raw.githubusercontent.com/heroku/buildpack-stdlib/master/stdlib.sh > /tmp/stdlib.sh && source /tmp/stdlib.sh
    
 This will make the following functions available: 
 
- `puts-line`, which outputs a line in a standardized format.
- `puts-step`, which outputs a build step in a standardized format.
- `puts-error`, which outputs a build error in a standarized format. 
- `puts-warn`, which outputs a build warning in a standardized format. 
- `set-env`, which writes an environment variable to a profile and export script (for multi-buildpack support). 
- `set-default-env`, which writes a default environment variable to a profile and export script (for multi-buildpack support). 
- `un-set-env`, which unsets a user-provided environment variable via profile script. 
- `sub-env`, which launches a subshell with user-provided config.
