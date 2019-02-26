# harness common env initialization script (meant to be sourced)

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

## Check system compatibilty
#
( which ps >& /dev/null && which grep >& /dev/null && which sed >& /dev/null ) || fail=yes
( ps -w &> /dev/null ) || fail=yes
if [ "$fail" = yes ]; then
  >&2 echo "System utilities required, please install:"
  >&2 echo "==> ps (gnu compatible with -w option), sed, grep!"
  exit 1
fi


## Print a status line "message .(...) value"
#
status_line() {
  local char="." total=64
  len=$((total - ${#1} - ${#2}))
  padding=$(printf "%-${len}s" "${char}")
  padding=${padding// /${char}}
  printf "%s ${padding} %s\n" "${1}" "${2}"
}


## Locate java of a class
#
java_pid() {
  local pid service_class="$1"
  ps -e ww -o pid,command | grep "\bjava .*${service_class}" | sed 's/^ *\([0-9]*\) .*/\1/'
}


## Check if harness is running
harness_running() {
  if [ "$1" = "-v" ]; then
    "${HARNESS_CLI_HOME}"/commands.py status "${USER_ARGS}"
  else
    "${HARNESS_CLI_HOME}"/commands.py status "${USER_ARGS}" &> /dev/null
  fi
}


## Wait for harness is running
waitfor_harness() {
  local checks=3 delay=2 timeout=${1:-30}

  while ( ! harness_running || [ "${checks}" -gt 0 ] ); do
    [ "${timeout}" -le 0 ] && break
    sleep $delay
    checks=$((checks - 1))
    timeout=$((timeout - delay))
  done

  harness_running
}
