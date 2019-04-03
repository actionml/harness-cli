.DEFAULT_GOAL := dist
.PHONY: clean clean-dist dist

HARNESS_CLI_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

PYTHON_SDK_DIR := $(HARNESS_CLI_ROOT)/python-sdk
PYTHON_CLI_DIR := $(HARNESS_CLI_ROOT)/python-cli
DIST ?= ./dist


clean:
	find $(HARNESS_CLI_ROOT) -name "__pycache__" -exec rm -r {} \; || true

clean-dist:
	cd $(DIST) && ls -1A | xargs rm -r || true

dist: clean clean-dist wheel
	mkdir -p $(DIST) && cd $(DIST) && mkdir
	cp $(RESTSRV_DIR)/$(PYTHON_CLI_DIR)/* $(DIST)
	echo $(date) > $(DIST)/RELEASE

wheel:
	mkdir -p $(DIST)
	pip3 wheel --wheel-dir=$(DIST)/wheel $(PYTHON_SDK_DIR)

