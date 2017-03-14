# buildpack-stdlib

A standard library for Heroku buildpacks.


## Usage

In your buildpack, run the following command (towards the top):

    $ curl https://raw.githubusercontent.com/heroku/buildpack-stdlib/master/stdlib.sh /tmp/stdlib.sh && source /tmp/stdlib.sh
    
 This will make the following functions available: 
 
 - 
