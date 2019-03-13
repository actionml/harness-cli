# The Harness CLI v0.2.0

The Harness Command Line Interface uses a connection to a running Harness Server to do administrative tasks.

## **PLEASE READ THESE NOTES** 

 - **Until we deprecate and remove** the integrated CLI this one will coexist and perform the same functions as the integrated one but with a new command-name `harness-cli status` instead of `harness status`. Once we switch this will become the only CLI and will go back to `harness status` etc
 - This CLI **cannot be used to start or stop** Harness, use the integrates cli to do this. `harness start` and `harness stop` should still work.
 - You must add the `harness-cli` script to your PATH and to be safe it should be before the embedded Harness CLI. 
 - **The Harness Python SDK is now included**: You will need to install the Harness Python SDK as well as dependent packages as shown in Setup.

These restrictions will be removed in future version of this project.

## Requirements

 - Python 3: Install so that it is executed with `python3` NOT `python`. Check with `which python3` or `python3 -version`
 - A running Harness Server
 - Linux, macOS, or other 'nix version

## Setup

To get the project do a git pull from the `develop` branch of this repo: https://github.com/actionml/harness-cli.git. The latest WIP is in `feature/cli-refactor`

Set your PATH env variable to point to the `harness-cli/python-cli` directory of this project **AND** make sure it is before the embedded CLI in `harness/dist/bin` or wherever you install the CLI that comes with the Harness repo.

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

To use this harness cli on a remote harness server make the correct changes to `python-cli/harness-cli-env` or in the shell's env, which overrides `harness-cli-env`.

For the simple case, just change `HARNESS_SERVER_ADDRESS` and `HARNESS_SERVER_PORT` in the setting below.

### Full Settings

These should allow full control of the CLI but the Auth-Server commands involving creating permissions, users, etc are not tested except in the embedded CLI.

```
# harness cli environment file (sourced by scripts)

# Harness CLI config, should work as-is unless you are using SSL or connecting to a remote Harness Server
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

# Roadmap

This will be converted completely to Python and will target many possible configs pointing to different harness servers. It will do this in a similar way to how git works by searching back from the current directory to find a `.harness` directory with a `config.yml` file. This will allow working directories to point to different instances. The `config.yml` file will have similar settings as the current `harness-cli-env`

Comments on this approach are welcome, leave them in the issues area of github.


