#!/usr/bin/env bash

harness_command="harness-cli"

$harness_command status | grep -q "OK"

retVal=$?
if [ $retVal -eq 0 ]; then
    echo "All OK!"
    exit 0
fi
exit $retVal
