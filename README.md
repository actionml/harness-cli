# The Harness CLI

The Harness Command Line Interface uses a connection to a running Harness Server to do administrative tasks. 

**Until we deprecate and remove the integrated CLI this one will coexist and perform the same functions as the integrated one but with a new command-name `harness-cli status` instead of `harness status`. Once we switch this will become the only CLI and will go back to `harness status` etc**

**Note:**This CLI cannot be used to start or stop Harness, use the integrates cli to do this.

## Requirements

 - Python 3
 - A running Harness Server
 - Linux or macOS (other 'nix versions may work too)

## Setup

If you are running Harness locally on `http://localhost:9090` you can just add the the path to `harness-client-cli/python-cli` to your `$PATH` in `~/.profile` or `~/.bashrc` or wherever your OS requires, no other config is required.

To use this harness cli on a remote harness server make the correct changes to `harness-cli-env` or in the env, which overrides `harness-cli-env`

For the simple case, just change `HARNESS_SERVER_ADDRESS` and `HARNESS_SERVER_PORT` in the setting below.

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

## Help

In a terminal shell type `harness-cli` to get help.

# Examples

The examples directory comes with some tests for the Universal Recommender that illustrate how to use this cli remotely and with several different configurations for a Harness cluster.

To use this setup with integration tests make the changes to the cli above then make sure the engine's JSON config used in the test has changes that reflect the harness installation's internal addressing for Elasticsearch and Spark. Check the engine's config `sparkConf` section for:

 -  `"master": "spark://some-spark-master:7077"` This shoudl point to the correct Spark master, or use `"local"` to use the Spark build-in to Harness
 -  `"es.nodes": "some-es-node-1,some-es-node2"` These shoudl be the IPs or DNS names of the ES nodes in the installation

Run the test with new params for the remote installation of harness like this:

 - `cd harness-cli/`
 - `./examples/ur/ur-integration-test.sh address-of-harness port-of-harness`

Note: Tests do not currently work with https.
 
The test will pause to allow training to finish, then again for permission to send queries. At the end it will compare actual results to expected ones and exit with 0 if the tests pass or 1 if they do not.

# Roadmap

This will be converted completely to Python and will target many possible configs pointing to different harness servers. It will do this in a similar way to how git works by searching back from the current directory to find a `.harness` directory with a `config.yml` file. This will allow working directories to point to different instances. The `config.yml` file will have similar settings as the current `harness-cli-env`

Comments on this approach are welcome, leave them in the issues area of github.