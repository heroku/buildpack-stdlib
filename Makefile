test: init
	tests/tests.sh

init:
	git submodule update --recursive --remote