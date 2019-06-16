.DEFAULT_GOAL := build
.PHONY: clean clean-dist dist

HARNESS_CLI_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

PYTHON_SDK_DIR := $(HARNESS_CLI_ROOT)/python-sdk
HARNESS_CLI_DIR := $(HARNESS_CLI_ROOT)/harness-cli
DIST ?= ./dist

# not sure where to get the version number so hard code?
# the version number of the sdk is in the python code and not to be used as the cli version number
# we should mirror the harness version number here
VERSION := 0.4.0-RC1

# For containers use the "dist" target
# to install on a host OS, use the "install" target or "dist install"
clean:
	find $(HARNESS_CLI_ROOT) -name "__pycache__" -exec rm -r {} \; || true

clean-dist:
	cd $(DIST) && ls -1A | xargs rm -r || true

dist: clean clean-dist build
	mkdir -p $(DIST) && cd $(DIST) && mkdir python-sdk harness-cli
	cp -r $(PYTHON_SDK_DIR)/* $(DIST)/python-sdk/
	cp $(HARNESS_CLI_DIR)/* $(DIST)/harness-cli/
	#date > $(DIST)/RELEASE
	# add the hard-coded version number to the date
	#echo $(VERSION) >> $(DIST)/RELEASE

build:
	mkdir -p $(DIST)
	pip3 wheel --wheel-dir=$(DIST)/wheel $(PYTHON_SDK_DIR)
	date > $(DIST)/RELEASE
	# add the hard-coded version number to the date
	echo $(VERSION) >> $(DIST)/RELEASE

# not needed for a container but used to re-install a new version on a host OS
install: build
	pip3 install $(DIST)/wheel/*.whl
