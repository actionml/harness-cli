[![CircleCI](https://circleci.com/gh/actionml/harness-cli.svg?style=svg)](https://circleci.com/gh/actionml/harness-cli)

# The Harness Control Client 

The Harness Command Line Interface uses a connection to a running Harness Server to perform administrative tasks.

**Major Changes:**

 - `hctl` is the preferred alternative to `harness-cli`. Both continue to function. This doc uses `harness-cli` but will switch to `hctl` in the next version.

# Requirements

 - Python 3: Install so that it is executed with `python3` NOT `python`. Check with `which python3` or `python3 -version`
 - A running Harness Server
 - Linux, macOS, or other 'nix version
 
 OR
 
 - use the harness-cli container published on docker hub [here](https://hub.docker.com/repository/docker/actionml/harness-cli).

## Installation and Setup

### Source Installation

To get the project do a git pull from the `develop` branch of this repo: https://github.com/actionml/harness-cli.git.

Set your PATH env variable to point to the `harness-cli/harness-cli` directory of this project **AND** make sure it is before the integrated (and deprecated) CLI in `harness/dist/bin` or wherever you install the CLI that comes with the Harness repo.

 1. Install the Harness Python SDK

 Depending on what OS and version of python3 you may need to install several packages from PyPI (the Python Package Index). For this you must first install `python3` and `pip3`

 For Ubuntu 16.04+

  - `sudo apt-get install python3 python3-pip`

 2. with pip3 install:

  - `pip3 install pytz`
  - `pip3 install datetime`
  - `pip3 install argparse`

 3. install the Harness Python Client SDK:

  - `cd harness-cli/python-sdk`
  - `python3 setup.py install`

 This will put the SDK in a place any python program can access

### Container Installation

After [installing Docker](https://docs.docker.com/engine/install/) either Engine or Desktop, proceed to install the `harness-cli` container. 
 
### Localhost

If you are running Harness locally on `http://localhost:9090` no other config is required. Once Harness is started, run `harness-cli status` to see where the cli is pointed and to get connection status.

### Remote Harness

To use this harness-cli on a remote harness server make the correct changes to `python-cli/harness-cli-env` or in the shell's env, which overrides `harness-cli-env`.

For the simple case, just change `HARNESS_SERVER_ADDRESS` and `HARNESS_SERVER_PORT` in the setting below.

### Full Settings

Various settings are passed into `harness-cli` via the host's env and will allow full control of the CLI or optionally you can edit `harness-cli/harness-cli/harness-cli-env`.

Notice that `HARNESS_CLI_HOME` should not be set since it is calculated internally.

**Deprecation Warning:** This env based configuration may be changed at any time so before all upgrades consult this README.

## Help

In a terminal shell type `harness-cli` to get help.

# Examples

The examples directory comes with some tests for the Universal Recommender that illustrate how to use this cli remotely and with several different configurations for a Harness cluster.

To use this setup with integration tests make the changes to the cli above then make sure the engine's JSON config used in the test has changes that reflect the harness installation's internal addressing for Elasticsearch and Spark. Check the engine's config `sparkConf` section for:

 -  `"master": "spark:<//some-spark-master>:7077"` This should point to the correct Spark master, or use `"local"` to use the Spark build-in to Harness
 -  `"es.nodes": "<some-es-node-1>,<some-es-node2>"` These should be the IPs or DNS names of the ES nodes in the installation, comma separated with no spaces, quotes or < > characters.

Run the test with new params for the remote installation of harness (harness-env must also point the cli to the correct location) like this:

 - `./examples/ur/ur-integration-test.sh <address-of-harness> <port-of-harness>`
 - The parameters default to `localhost` and `9090`

At the end it will compare actual results to expected ones and exit with 0 if the tests pass or 1 if they do not.

**Deprecation Warning:** The tests are a work in progress so expect changes.

# Containers

This project is published as a docker image with tags of the form: `actionml/harness-cli:<tag>` where supported tags are:

 - `latest`: most recent stable release, the most recent version of code tagged and pushed to the master branch of the git repo as an official release.
 - `develop`: the most recent version of the work-in-progress. The most recent commit to the git `develop` branch. See the commit tag to find the last 6 characters of exact git commit number.
 - `0.5.1-RC1`, `0.6.0`, ...: release tags by version, which will match the tag in the git repo.

## Running the `harness-cli` Container

Typically this container is used in a Kubernetes or docker-compose deployments with Harness itself (and other required services). In these cases the Harness server address is passed to this container by the orchestration layer.

It is also convenient to run this container when controlling a remote Harness server or even during development where harness is running locally on `localhost:9090`. Here's how:

```
docker run -d -e HARNESS_EXTERNAL_ADDRESS=192.0.0.4 actionml/harness-cli:develop 
```

 - replace the tag with the version of the cli you want
 - replace `HARNESS_EXTERNAL_ADDRESS` with the Harness address. For Harness running on `localhost` you must still provide the LAN address of the server, "localhost" will not be sufficient in most environments.

Now find container id and start bash inside the running container

```
$ docker ps
CONTAINER ID        IMAGE                         COMMAND                  CREATED             STATUS              PORTS                              NAMES
f87d1403aca9        actionml/harness-cli:develop   "tail -f /dev/null"      30 minutes ago      Up 30 minutes                                          harness-docker-compose_harness-cli_1
$ docker exec -it f87d1403aca9 bash
root@f87d1403aca9:/# harness-cli status
Harness CLI settings
==================================================================
HARNESS_CLI_HOME ........................ /harness-cli/harness-cli
HARNESS_CLI_SSL_ENABLED .................................... false
HARNESS_CLI_AUTH_ENABLED ................................... false
HARNESS_SERVER_ADDRESS ................................. 192.0.0.4
HARNESS_SERVER_PORT ......................................... 9090
==================================================================
Harness Server status: OK
root@f87d1403aca9:/# harness-cli status engines
[]
root@f87d1403aca9:/# 
```

The "status" gives an "OK" if connections can be made, the rest of the info is client config. The "status engines" hits the DB to find any installed engines so if you have new Harness installation you will get an empty JSON array of Engine Instance info.

# Versions

The Harness-CLI follows the same version numbers as the Harness Server. If you build from source there will be a git tag in the master branch for every release after 0.4.0-RC1. For containers the image tags also follow Harness naming.

## harness-cli version 1.0.0-SNAPSHOT

Synced with harness-1.0.0-SNAPSHOT. No planned changes from 0.6.0. This version is in the "develop" branch of this repo.

## harness-cli version 0.6.0

This is in sync with Harness 0.6.0 but should be backward compatible with all 0.5.x harness versions.

New features:

 - `harness-cli` now has an alias of `hctl` which is the preferred invocation. 
 - Some slight edits to command responses for clarity. These include the renaming of "_id" to "name" in the JSON response for `hctl status engines`.

## 0.5.0 changes from v0.4.0

 - **This CLI replaces** the one integrated with Harness in Harness 0.4.0.
 - This CLI **cannot be used to start or stop** Harness, the integrated `harness start` and `harness stop` in the Harness project should work.
 - You must add the `harness-cli` script to your PATH.
 - **The Harness Python SDK is now included** in this project: You will need to install the Harness Python SDK as well as dependent packages as shown in Setup below.

