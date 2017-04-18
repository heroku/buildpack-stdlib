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

# This script expects the AWS_ACCESS_KEY_ID and
# AWS_SECRET_ACCESS_KEY environment variables to be set,
# as well as all dependencies to be installed (pipenv install).

import sys

import bucketstore
from docopt import docopt

bucket = bucketstore.get('lang-common', create=False)
prefix = 'buildpack-stdlib/'


def do_list():

    for entry in bucket.list():
        if entry.startswith(prefix):
            if entry.endswith('/'):
                if 'latest' not in entry:
                    entry = entry[len(prefix):-1]
                    if entry:
                        print entry

def upload(version):
    key = '{0}{1}/stdlib.sh'.format(prefix, version)

    with open('stdlib.sh', 'rb') as f:
        bucket[key] = f.read()

    print key


def do_upload(version, latest=False):
    print 'Uploading \'stdlib.sh\' to Amazon S3 bucket {0!r}...'.format(bucket.name)

    # Actually upload the version specified.
    upload(version)

    # Actually update latest to this version.
    if latest:
        upload('latest')

    # Report a clean installation.
    print 'Complete!'


def main():
    arguments = docopt(__doc__, version='Naval Fate 2.0')

    if arguments['--list']:
        do_list()
        sys.exit(0)

    if arguments['<v>']:
        do_upload(version=arguments['<v>'], latest=arguments['--latest'])

    else:
        'A version (e.g. \'v1\') must be provided!'
        sys.exit(1)

if __name__ == '__main__':
    main()