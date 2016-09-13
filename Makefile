# Double build systems, you say?
# Consider this the documentation file that contains the authoritative
# instructions for testing, via cmake (the primary build system).

UNAME := $(shell uname)
CMAKE_OPTS := -DLOW_MEMORY_NODE=On

ifeq ($(UNAME), Linux)
MAKEOPTS := -j$(shell nproc)
endif

.PHONY: docker build test install submodule_init clean

submodule_init:
	git submodule update --init --recursive

# note that we are not yet 'steemit' org on docker hub. :/
# if you are the owner of this org/username, please contact
# us, as we would like to make the dockerhub path the same as github
# (`steemit/steem').
docker:
	docker build --rm=false -t steemit/steem .

build/Makefile:
	mkdir build
	cd build && cmake $(CMAKE_OPTS) \
		-DCMAKE_BUILD_TYPE=Release \
	..

build: build/Makefile
	cd build && make $(MAKEOPTS)

test: submodule_init clean
	mkdir build
	cd build && cmake $(CMAKE_OPTS) \
		-DCMAKE_BUILD_TYPE=Debug \
		-DBUILD_STEEM_TESTNET=On \
	..
	cd build && make $(MAKEOPTS) chain_test
	cd build && ./tests/chain_test
	make clean

install: build
	cd build && make install

clean:
	rm -rf build
