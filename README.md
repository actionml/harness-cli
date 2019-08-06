[![CircleCI](https://circleci.com/gh/actionml/harness-cli.svg?style=svg)](https://circleci.com/gh/actionml/harness-cli)

# The Harness Control Client 
### **Version 0.5.0, for Harness 0.5.0**

The Harness Command Line Interface uses a connection to a running Harness Server to perform administrative tasks. Out of the box it is configured to communicate with http://localhost:9090 but a simple change will point it to any Harness server.

## Deprecation Notes 

 - **This CLI duplicates and replaces** the one integrated in Harness 0.4.0. The integrated CLI will be removed in Harness-0.5.0-SNAPSHOT and replaced by this one. Until we deprecate and remove the integrated CLI this one will coexist and performs the same functions as the integrated one but with a new command-name `harness-cli status` instead of `harness status`. Once we switch this will become the only CLI and will become`harness-cli status` etc.
 - This CLI **cannot be used to start or stop** Harness, use the integrated cli to do this. `harness start` and `harness stop` should work.
 - You must add the `harness-cli` script to your PATH and to be safe it should be before the integrated CLI. 
 - **The Harness Python SDK is now included** in this project: You will need to install the Harness Python SDK as well as dependent packages as shown in Setup below.

## Requirements

 - Python 3: Install so that it is executed with `python3` NOT `python`. Check with `which python3` or `python3 -version`
 - A running Harness Server
 - Linux, macOS, or other 'nix version

## Setup

To get the project do a git pull from the `develop` branch of this repo: https://github.com/actionml/harness-cli.git.

Set your PATH env variable to point to the `harness-cli/harness-cli` directory of this project **AND** make sure it is before the integrated (and deprecated) CLI in `harness/dist/bin` or wherever you install the CLI that comes with the Harness repo.

### Install the Harness Python SDK

Depending on what OS and version of python3 you may need to install several packages from PyPI (the Python Package Index). For this you must first install `python3` and `pip3`

For Ubuntu 16.04+

 - `sudo apt-get install python3 python3-pip`

Then with pip3 install:

 - `pip3 install pytz`
 - `pip3 install datetime`
 - `pip3 install argparse`

Then install the Harness Python Client SDK:

 - `cd harness-cli/python-sdk`
 - `python3 setup.py install`

This will put the SDK in a place any python program should be able to access it. and this is important because the Harness Python CLI uses the SDK.

### Localhost

If you are running Harness locally on `http://localhost:9090` no other config is required. Once Harness is started, run `harness-cli status` to see where the cli is pointed and to get connection status.

### Remote Harness

To use this harness-cli on a remote harness server make the correct changes to `python-cli/harness-cli-env` or in the shell's env, which overrides `harness-cli-env`.

For the simple case, just change `HARNESS_SERVER_ADDRESS` and `HARNESS_SERVER_PORT` in the setting below.

### Full Settings

These should allow full control of the CLI but the Auth-Server commands involving creating permissions, users, etc are not tested except in the embedded CLI.

```
# harness-cli environment file (sourced by scripts)

# harness-cli config, should work as-is unless you are using SSL or connecting to a remote Harness Server
export HARNESS_SERVER_ADDRESS=${HARNESS_SERVER_ADDRESS:-localhost}
export HARNESS_SERVER_PORT=${HARNESS_SERVER_PORT:-9090}

# Java and Python client SDKs use the following for TLS/SSL, not used by the server
# the file provided works with localhost, create your own for some other IP address
export HARNESS_CLI_CERT_PATH=${HARNESS_CLI_CERT_PATH:-$HARNESS_CLI_HOME/harness.pem}

# =============================================================
# Only change to enable TLS/SSL
# =============================================================

# export HARNESS_CLI_SSL_ENABLED=true # to enable TLS/SSL using the rest below for "localhost" keys passwords and certs
export HARNESS_CLI_SSL_ENABLED=false

# Harness TLS/SSL server support. A file needs to be provided even if TLS is not used, one is supplied for "localhost"
#export HARNESS_KEYSTORE_PASSWORD=${HARNESS_KEYSTORE_PASSWORD:-changeit}
#export HARNESS_KEYSTORE_PATH=${HARNESS_KEYSTORE_PATH:-$HARNESS_CLI_HOME/conf/harness.jks}

# =============================================================
# Only used for Authentication
# =============================================================

# Harness Auth-Server setup
# export HARNESS_CLI_AUTH_ENABLED=true
export HARNESS_CLI_AUTH_ENABLED=${HARNESS_CLI_AUTH_ENABLED:-false}
# When auth is enabled there must be an admin user-id set so create one before turning on Auth
# Both the Harness server and the Python CLI need this env var when using Auth
# export ADMIN_USER_ID=some-user-id
# The Python CLI needs to pass the user-id and user-secret to the Python SDK so when using Auth supply a pointer to
# the user-secret here.
# export ADMIN_USER_SECRET_LOCATION=${ADMIN_USER_SECRET_LOCATION:-"$HOME/.ssh/${ADMIN_USER_ID}.secret"}

```

Notice that `HARNESS_CLI_HOME` should not be set since it is calculated internally.

**Deprecation Warning:** This env based configuration will eventually be replaced with a different scheme using YAML files. Before all upgrades consult this README.

## Help

In a terminal shell type `harness-cli` to get help.

# Examples

The examples directory comes with some tests for the Universal Recommender that illustrate how to use this cli remotely and with several different configurations for a Harness cluster.

To use this setup with integration tests make the changes to the cli above then make sure the engine's JSON config used in the test has changes that reflect the harness installation's internal addressing for Elasticsearch and Spark. Check the engine's config `sparkConf` section for:

 -  `"master": "spark:<//some-spark-master>:7077"` This should point to the correct Spark master, or use `"local"` to use the Spark build-in to Harness
 -  `"es.nodes": "<some-es-node-1>,<some-es-node2>"` These should be the IPs or DNS names of the ES nodes in the installation, comma separated with no spaces, quotes or < > characters.

Run the test with new params for the remote installation of harness like this:

 - `./examples/ur/ur-integration-test.sh <address-of-harness> <port-of-harness>`
 - The parameters default to `localhost` and `9090`

Note: Tests do not currently work with https.
 
The test will pause to allow hand start of training and finishing training to start queries. At the end it will compare actual results to expected ones and exit with 0 if the tests pass or 1 if they do not.

**Deprecation Warning:** The tests are a work in progress so expect changes as they are refactored. Consult this README before any upgrade.

# Versions

The Harness-CLI follows the same version numbers as the Harness Server. If you build from source there will be a git tag in the master branch for every release after 0.4.0-RC1. For containers the image tags also follow Harness naming.

# Containers

This project is published as `actionml/harness-cli:<tag>` where supported tags are:

 - `latest`: most recent stable release, the most recent version of code tagged and pushed to the master branch of the git repo.
 - `develop`: the most recent version of the work-in-progress. The most recent commit to the git `develop` branch. See the commit number tag to find the exact commit.
 - `0.4.0-RC1`, `0.4.0`: release tags by version, which will match the tag in the master branch of the git repo.

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

