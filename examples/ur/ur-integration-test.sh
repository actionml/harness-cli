#!/usr/bin/env bash
set -e
echo
echo "Usage: ur-integration-test.sh [harness-url harness-port spark-master-url elasticsearch-master-url]"
echo "run from harness-cli/, assumes all params passed in or none (for localhost everything)"
echo "export HARNESS_CLIENT_USER_ID and HARNESS_CLIENT_USER_SECRET before running against"
echo "Harness with TLS and Auth? ** Untested **"
echo

# Since the Cli needs to know harness and the engine's json will grab spark and elasticsearch from the env
# we assume all ar localhost or all will be passed in

if [ -z "$1" ] ; then
  training_sleep_seconds=30
  sleep_seconds=1
  export HARNESS_SERVER_ADDRESS=localhost
  export HARNESS_SERVER_PORT=9090
  export ELASTICSEARCH_MASTER=${ELASTICSEARCH_MASTER:-http://localhost:9200}
  export SPARK_MASTER="local"

else
  training_sleep_seconds=90 # wait longer for remote machine
  export HARNESS_SERVER_ADDRESS=${1}
  export HARNESS_SERVER_PORT=${2}
  export ELASTICSEARCH_MASTER=${3}
  export SPARK_MASTER=${4}
  export
fi

export harness_url=http://${HARNESS_SERVER_ADDRESS}":"${HARNESS_SERVER_PORT}
# only need 4g for this test
echo
echo "Test config whih overrides the setting in harness-cli-env"
echo
echo "Harness server:............. $HARNESS_SERVER_ADDRESS"
echo "Harness port:............... $HARNESS_SERVER_PORT"
echo "Harness URL:................ $harness_url"
echo "Elasticesrch Spark address.. $ELASTICSEARCH_MASTER"
echo "Spark Master................ $SPARK_MASTER"
echo

# several flags are passed in via export from the integration test, otherwise they are undefined
# so this script will execute the defaults

# point to the harness host, use https://... for SSL and set the credentials if using Auth
# export "HARNESS_CLIENT_USER_ID"=xyz
# export "HARNESS_CLIENT_USER_SECRET"=abc

# set harness-env to point to the correct server for executing these tests
diffs_and_errors_file=diffs_and_errors.txt
# for real CLI test: engine=test_ur_nav_hinting
engine=test_ur
engine_json=examples/ur/ur_test_mobile_device.json
test_queries=examples/ur/test-ur-mobile-device-queries.sh
user_events=examples/ur/sample-mobile-device-ur-data.csv
actual_query_results=actual_ur_results.out


# initialize these in case not running from integrated test script
skip_restarts=${skip_restarts:-true}
clean_test_artifacts=${clean_test_artifacts:-false}
expected_test_results=examples/ur/expected-ur-results.txt


if [ "$skip_restarts" = false ]; then
    harness-cli stop
    harness-cli start -f
    sleep 10
fi

echo
echo "----------------------------------------------------------------------------------------------------------------"
echo "Universal Recommender Integration tests"
echo "----------------------------------------------------------------------------------------------------------------"
echo
#: <<'END' # block comment beginning look for END

echo "---------------------- Testing Simple Personalized Recs with Business Rules         ----------------------------"


echo "Wipe the Engine clean of data and model first"
harness-cli delete ${engine}
sleep $sleep_seconds
harness-cli add ${engine_json} || true
sleep $sleep_seconds

echo
echo "Sending all personalization events"
echo
python3 examples/ur/import_mobile_device_ur_data.py --input_file ${user_events} --url ${harness_url}

echo
echo "Training a new model--THIS WILL TAKE SOME TIME (30 SECONDS?)"
echo
#read -n1 -r -p "Press a key to start clustered training..." key

echo ">>>>>>>>>> ES >>>>>>>>>>>>>>>"
echo $ELASTICSEARCH_MASTER
harness-cli train $engine
sleep $training_sleep_seconds # wait for training to complete

echo
echo "Sending UR queries"
echo
#read -n1 -r -p "Press a key to send queries..." key

./${test_queries} ${harness_url} > ${actual_query_results}

#END
: <<'END' # block comment beginning look for END

echo
echo "---------------------- Testing Event Aliases -------------------------------------------------------------------"

engine_aliases_json=examples/ur/localhost_test_ur_mobile_aliases.json
user_events_aliases=examples/ur/sample-event-alias-ur-data.csv
actual_query_results_aliases=actual_ur_aliases_results.out

echo "Wipe the Engine clean of data and model first"
harness-cli delete ${engine}
sleep $sleep_seconds
harness-cli add ${engine_aliases_json} || true
sleep $sleep_seconds

echo
echo "Sending all personalization events"
echo
python3 examples/ur/import_mobile_device_ur_data.py --input_file ${user_events_aliases} --url ${harness_url}

echo
echo "Training a new model--THIS WILL TAKE SOME TIME (30 SECONDS?)"
echo
harness-cli train $engine
sleep $training_sleep_seconds # wait for training to complete

echo
echo "Sending UR queries"
echo
./${test_queries} ${harness_url} > ${actual_query_results_aliases}

#END
#: <<'END' # block comment beginning look for END

echo "---------------------- Testing Queries Filtered by Dates -------------------------------------------------------"


engine_dates_json=examples/ur/localhost_test_ur_mobile_device_dates.json
user_events_dates=examples/ur/sample-mobile-device-ur-data.csv
actual_query_results_dates=actual_ur_dates_results.out
expected_test_results_dates=examples/ur/expected-ur-date-results.txt
test_date_queries=examples/ur/test-ur-mobile-date-queries.sh


echo "Wipe the Engine clean of data and model first"
harness-cli delete ${engine}
sleep $sleep_seconds
harness-cli add ${engine_dates_json} || true
sleep $sleep_seconds

echo
echo "Sending all personalization events with dates"
echo
python3 examples/ur/import_mobile_device_ur_data.py --input_file ${user_events_dates} --with_dates true  --url ${harness_url}

echo
echo "Training a new model--THIS WILL TAKE SOME TIME (30 SECONDS?)"
echo
harness-cli train $engine
sleep $training_sleep_seconds # wait for training to complete

echo
echo "Sending UR queries"
echo

./${test_date_queries} ${harness_url} > ${actual_query_results_dates}
#END

# echo "---------------------- Below there should be no differences reported -------------------------------------------"
set +e # ignore trivial errors like no grep match

rm -f ${diffs_and_errors_file}

##echo "default" >> ${diffs_and_errors_file}
diff ${actual_query_results} ${expected_test_results} | grep "result" >> ${diffs_and_errors_file}
cat ${actual_query_results} | grep "error" >> ${diffs_and_errors_file}

##echo "aliases" >> ${diffs_and_errors_file}
diff ${actual_query_results_aliases} ${expected_test_results} | grep "result" >> ${diffs_and_errors_file}
cat ${actual_query_results_aliases} | grep "error"  >> ${diffs_and_errors_file}

##echo "date filters" >> ${diffs_and_errors_file}
diff ${actual_query_results_dates} ${expected_test_results_dates} | grep "result"  >> ${diffs_and_errors_file}
cat ${actual_query_results_dates} | grep "error" >> ${diffs_and_errors_file}


if [ -s ${diffs_and_errors_file} ]
then
   echo " Some differences between actual and expected or server errors, check the actual results files. "
   cat ${diffs_and_errors_file}
   exit 1
else
   echo "Tests pass."
   exit 0
fi
END
