#!/usr/bin/env bash
set +e
echo
echo "Usage: simple-integration-test.sh"
echo "run from harness-cli/, assumes http for the Harness REST endpoint"
echo "Set HARNESS_SERVER_ADDRESS and HARNESS_SERVER_PORT before running"
echo "if you want to use a non-localhost Harness"
echo

export HARNESS_SERVER_ADDRESS=${HARNESS_SERVER_ADDRESS:-localhost}
export HARNESS_SERVER_PORT=${HARNESS_SERVER_PORT:-9090}
export host_url="http://${HARNESS_SERVER_ADDRESS}:${HARNESS_SERVER_PORT}"

if [ -z "$1" ] ; then
  training_sleep_seconds=30
  sleep_seconds=1
  DEPLOYMENT_STYLE="all-localhost"
  engine_json=examples/ur/simple_test_ur_mobile_device_host_install.json
else # if you pass any flag for style
  training_sleep_seconds=120 # wait longer for remote machine
  DEPLOYMENT_STYLE="k8s"
  engine_json=examples/ur/simple_test_ur_mobile_device_k8s_install.json
fi

echo "Harness address: $HARNESS_SERVER_ADDRESS"
echo "Harness port: $HARNESS_SERVER_PORT"
echo "Full Harness URL: $host_url"
echo "Deployment style: $DEPLOYMENT_STYLE"

# set harness-env to point to the correct server for executing these tests
diffs_and_errors_file=diffs_and_errors.txt
# for real CLI test: engine=test_ur_nav_hinting
engine=test_ur
test_queries=examples/ur/test-ur-mobile-device-queries.sh
user_events=examples/ur/sample-mobile-device-ur-data.csv
actual_query_results=actual_ur_results.out
expected_test_results=examples/ur/expected-ur-results.txt


echo
echo "----------------------------------------------------------------------------------------------------------------"
echo "Universal Recommender Integration tests"
echo "----------------------------------------------------------------------------------------------------------------"
echo

echo "---------------------- Testing Simple Personalized Recs with Business Rules         ----------------------------"


echo "Wipe the Engine clean of data and model first"
harness-cli delete ${engine}
sleep $sleep_seconds
harness-cli add ${engine_json} || true
sleep $sleep_seconds

echo
echo "Sending all personalization events"
echo
python3 examples/ur/import_mobile_device_ur_data.py --input_file ${user_events} --url ${host_url}

echo
echo "Training a new model--THIS WILL TAKE SOME TIME (30 SECONDS?)"
echo
#read -n1 -r -p "Press a key to start clustered training..." key

harness-cli train $engine
sleep $training_sleep_seconds # wait for training to complete

echo
echo "Sending UR queries"
echo
#read -n1 -r -p "Press a key to send queries..." key

./${test_queries} ${host_url} > ${actual_query_results}
# echo "Queries sent"

diff ${actual_query_results} ${expected_test_results} | grep "result" > ${diffs_and_errors_file}
cat ${actual_query_results} | grep "error" >> ${diffs_and_errors_file}

# echo "Getting diffs"
if [ -s ${diffs_and_errors_file} ]
then
   echo " Some differences between actual and expected or server errors, check the actual results files. "
   cat ${diffs_and_errors_file}
   exit 1
else
   echo "Tests pass."
   exit 0
fi
