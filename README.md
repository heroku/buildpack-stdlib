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
