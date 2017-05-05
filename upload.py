"""Buildpack Standard Library Uploader.

Usage:
  upload.py
  upload.py (-l | --list)
  upload.py <v> [--latest]

Options:
  -h --help     Show this screen.
  --version     Show version.
  -l --list     List versions aleady uploaded.
  --latest      Uploads the version to 'latest' as well.

WARNING: This script will automatically upload the 'stdlib.sh' script to
S3 as the latest release if given no arguments.

This script expects the AWS_ACCESS_KEY_ID and
AWS_SECRET_ACCESS_KEY environment variables to be set,
as well as all dependencies to be installed (pipenv install).
"""



import sys

import bucketstore
import crayons
from parse import parse
from docopt import docopt


# S3 Bucket.
bucket = bucketstore.get('lang-common', create=False)
prefix = 'buildpack-stdlib/'

def do_list():
    """Prints uploaded versions to console."""
    print crayons.yellow('Versions of buildpack standard library available on Amazon S3:')
    for version in iter_versions():
        print ' - {0}'.format(version)

def iter_versions():
    """Yields uploaded versions."""
    for entry in bucket.list():
        results = parse("buildpack-stdlib/{version}/stdlib.sh", entry)
        if results:
            yield results['version']

def next_version():
    """Returns the next version string."""
    return 'v{0}'.format(int(list(iter_versions())[-1][1:]) +1)

def upload(version):
    """Uploads a given version to S3."""
    key = '{0}{1}/stdlib.sh'.format(prefix, version)

    with open('stdlib.sh', 'rb') as f:
        bucket[key] = f.read()

    # Make key public.
    bucket.key(key).make_public()

    print key


def do_upload(version, latest=False):
    """Console function for uploading script to S3."""
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

    # Just list the uploaded versions.
    if arguments['--list']:
        do_list()
        sys.exit(0)

    # An explicit version was specified..
    if arguments['<v>']:
        do_upload(version=arguments['<v>'], latest=arguments['--latest'])

    else:
        v = next_version()
        print 'No version (e.g. \'{0}\') Provided, assuming latest!'.format(v)

        print 'Uploading {0}, and updating --latest...'.format(v)
        do_upload(version=v, latest=True)

if __name__ == '__main__':
    main()