all: check test unit
check:
	shellcheck stdlib.sh test/unit
test:
	bats tests.bats
unit:
	bash test/unit
