.DEFAULT_GOAL := build
.PHONY: sbt clean build

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SBT_URL ?= https://git.io/sbt
SBT ?= $(ROOT)/target/sbt/sbt

SCALA_VERSION := $(shell grep ^scalaVersion $(ROOT)/build.sbt | grep -o '".*"' | sed 's/"//g')

# Install sbtx locally
sbt:
ifeq ($(SBT),$(ROOT)/target/sbt/sbt)
	@ SBT_DIR="$$(dirname $(SBT))" && mkdir -p $$SBT_DIR && cd $$SBT_DIR && \
	[ -x sbt ] || ( echo "Installing sbt extras locally (from $(SBT_URL))"; \
		which curl &> /dev/null && ( curl \-#SL -o sbt \
			https://git.io/sbt && chmod 0755 sbt || exit 1; ) || \
			( which wget &>/dev/null && wget -O sbt https://git.io/sbt && chmod 0755 sbt; ) \
	)
endif


build: sbt
	cd $(ROOT) && \
		$(SBT) ++$(SCALA_VERSION) -batch stage

clean: sbt
	cd $(ROOT) && \
		$(SBT) ++$(SCALA_VERSION) -batch clean
	find $(ROOT) -name "__pycache__" -exec rm -r {} \; || true
