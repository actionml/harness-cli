# The Harness CLI

The Harness Command Line Interface uses a connection to a running Harness Server to do administrative tasks. 

**Until we integrate this CLI and the integrated one is removed from harness use this one with `harness-cli status` etc instead of `harness status`. This is so the 2 can co-exist until a full switchover is made to this version.**

**Note:**The CLI cannot be used to start or stop Harness, See the Harness Server documents for how to do this.

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

The examples directory comes with some tests for the Universal Recommender that illustrate how to use this cli remotely and with several different configurations for the Harness cluster.

To use this setup with integration tests make the changes to the cli above then run the test with new params for the remote installation of harness like this:

 - `cd harness-cli/`
 - `./examples/ur/ur-integration-test.sh address-of-harness port-of-harness`

The tests do not currently work with https.
 
The test will pause to allow training to finish, then again for permission to send queries. At the end it will compare actual results to expected ones and exit with 0 if the tests pass or 1 if they do not.
