all: check test
check:
	shellcheck stdlib.sh
test:
	bats tests.bats
