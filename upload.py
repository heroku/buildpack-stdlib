"""Buildpack Standard Library Uploader.

Usage:
  upload.py (-l | --list)
  upload.py <v> [--latest]

Options:
  -h --help     Show this screen.
  --version     Show version.
  -l --list     List versions aleady uploaded.
  --latest      Uploads the version to 'latest' as well.

"""

import bucketstore
from docopt import docopt

bucket = bucketstore.get('lang-common', create=False)

def do_list():

    prefix = 'buildpack-stdlib/'

    for entry in bucket.list():
        if entry.startswith(prefix):
            if entry.endswith('/'):
                if 'latest' not in entry:
                    entry = entry[len(prefix):-1]
                    if entry:
                        print entry


def main():
    arguments = docopt(__doc__, version='Naval Fate 2.0')

    if arguments['--list']:
        do_list()
        exit()

if __name__ == '__main__':
    main()