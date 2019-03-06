# harness common env initialization script (meant to be sourced)

# Reset
export NC='\033[0m'           # Text Reset

# Regular Colors
export RED='\033[0;31m'          # Red--error
export GREEN='\033[0;32m'        # Green
export YELLOW='\033[0;33m'       # Yellow
export BLUE='\033[0;34m'         # Blue
export PURPLE='\033[0;35m'       # Purple
export CYAN='\033[0;36m'         # Cyan--hints and info messages
export WHITE='\033[0;37m'        # White


## BSD/MacOS compatible readlink -f
#
_readlink_f() {
  target=$1
  cd $(dirname $target)
  target=$(basename $target)

  while [ -L "$target" ]; do
      target=$(readlink $target)
      cd $(dirname $target)
      target=$(basename $target)
  done

  physical_directory=$(pwd -P)
  echo $physical_directory/$(basename $target)
}

#echo `basename $(dirname $(dirname $0))`
#echo $(dirname $(dirname $0))
#echo $(dirname $0)
#echo $(dirname `_readlink_f $0`)

# export $HARNESS_CLI_HOME if not set
if [ -z "${HARNESS_CLI_HOME}" ]; then
  if [ -z "$(which readlink 2>/dev/null)" ]; then
    echo -e "${RED}readlink command must be present on your system!${NC}"
    exit 1
  fi

  #bindir=$(dirname `_readlink_f $0`)
  # trim the last path element (which is supposed to be /bin(/))
  #export $HARNESS_CLI_HOME=${bindir%/*}
  export HARNESS_CLI_HOME=$(dirname `_readlink_f $0`)
fi


# source the harness-cli-env file
. "${HARNESS_CLI_ENVFILE:-${HARNESS_CLI_HOME}/harness-cli-env}"

if [ "${HARNESS_CLI_AUTH_ENABLED}" != "true" ]; then
  USER_ARGS=""
elif [ ! -z "$ADMIN_USER_ID" ] && [ ! -z "$ADMIN_USER_SECRET_LOCATION" ] && [ "${HARNESS_CLI_AUTH_ENABLED}" = "true" ]; then
  USER_ARGS=" --client_user_id ${ADMIN_USER_ID} --client_user_secret_location ${ADMIN_USER_SECRET_LOCATION} "
else
  echo -e "${RED}Admin ID and Auth mis-configured see bin/harness-cli-env. If you want auth enabled all these must be set ${NC}"
  echo -e "${RED}ADMIN_USER_ID, ADMIN_USER_SECRET_LOCATION, HARNESS_CLI_AUTH_ENABLED${NC}"
  exit 1
fi
export USER_ARGS
