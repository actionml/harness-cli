#!/usr/bin/env bash

echo
echo "Usage: contextual-bandit-integration-test.sh host port"
echo "run from harness-cli"
echo "Uses no TLS no Auth"
echo

# several flags are passed in via export from the integration test, otherwise they are undefined
# so this script will execute the defaults


if [ -z "$1" ] ; then
  export HARNESS_SERVER_ADDRESS=localhost
  export HARNESS_SERVER_PORT=9090
  export host_url="http://localhost:9090"

else
  export host_url=http://${1}":"${2}
  export HARNESS_SERVER_ADDRESS=${1}
  port=$2
  export HARNESS_SERVER_PORT=${port:-9090}
fi

sleep_seconds=2
harness_command=harness-cli
test_home=`pwd`
test_dir="${test_home}/examples/cb"

echo "Test home: ${test_dir}"

# initialize these in case not running from integrated test script
skip_restarts=${skip_restarts:-true} # cannot easily restart in containers
clean_test_artifacts=${clean_test_artifacts:-false}
engine_1=test_cb_1
engine_2=test_cb_2
actual_results_file=actual_cb_results.txt

echo
echo "----------------------------------------------------------------------------------------------------------------"
echo "TESTING SIMILAR PROFILES, 2 PEOPLE \$set, INTO 2 DIFFERENT ENGINES"
echo "----------------------------------------------------------------------------------------------------------------"
${harness_command} delete ${engine_1}
sleep $sleep_seconds # sleep to allow the VW daemon to clear the model
sleep $sleep_seconds
${harness_command} delete ${engine_2}
sleep $sleep_seconds
${harness_command} add ${test_dir}/${engine_1}.json
sleep $sleep_seconds
${harness_command} add ${test_dir}/${engine_2}.json
# ${harness_command} status
# ${harness_command} status engines ${engine_1}
# ${harness_command} status engines ${engine_2}

# The test is to create 2 engines, 2 users with profile data convert on the same variant in one engine and only
# one user converts on a variant on the second engine. both engines should return the same variant for both users
# because profile is in common.

echo "Import events to create testGroup: 1, user: joe, and one conversion event with location new york to cb_test_1"
#mvn compile
# mvn exec:java -Dexec.mainClass="EventsClientExample" -Dexec.args="$1 $2 $3" -Dexec.cleanupDaemonThreads=false
# mvn exec:java -Dexec.mainClass="EventsClientExample" -Dexec.args="$host $engine_1 data/joe-profile-location.json" -Dexec.cleanupDaemonThreads=false

${harness_command} import ${engine_1} ${test_dir}/joe-profile-location.json
sleep $sleep_seconds
sleep $sleep_seconds

echo "Import events to create testGroup: 1, user: john, and one conversion event with location new york to cb_test_1"

# mvn exec:java -Dexec.mainClass="EventsClientExample" -Dexec.args="$host $engine_1 data/john-profile-location.json" -Dexec.cleanupDaemonThreads=false

${harness_command} import ${engine_1} ${test_dir}/john-profile-location.json
sleep $sleep_seconds
sleep $sleep_seconds

echo "Import events to create testGroup: 1, user: john, and one conversion event with location new york to test_cb_2"
#mvn exec:java -Dexec.mainClass="EventsClientExample" -Dexec.args="$host $engine_2 data/joe-profile-location.json" -Dexec.cleanupDaemonThreads=false
${harness_command} import ${engine_2} ${test_dir}/joe-profile-location.json
sleep $sleep_seconds
sleep $sleep_seconds

echo "Sending queries for joe and john to test_cb_1"

#mvn exec:java -Dexec.mainClass="QueriesClientExample" -Dexec.args="$host $engine_1 data/2-user-query.json" -Dexec.cleanupDaemonThreads=false >> test-profile-results.txt
${test_dir}/2-user-query.sh ${host_url} ${engine_1} > ${actual_results_file} # FIRST write will erase previous!!!


echo "Sending queries for joe and john to test_cb_2"
#mvn exec:java -Dexec.mainClass="QueriesClientExample" -Dexec.args="$host $engine_2 data/2-user-query.json" -Dexec.cleanupDaemonThreads=false >> test-profile-results.txt
${test_dir}/2-user-query.sh ${host_url} ${engine_2} >> ${actual_results_file} # SECOND write appends...

: <<'END' # block comment beginning look for END

echo
echo "----------------------------------------------------------------------------------------------------------------"
echo "TESTING SIMILAR BEHAVIORS, 2 PEOPLE'S CONVERSIONS, INTO 2 DIFFERENT ENGINES"
echo "----------------------------------------------------------------------------------------------------------------"
echo
${harness_command} delete $engine_1
sleep $sleep_seconds
${harness_command} delete $engine_2
sleep $sleep_seconds
${harness_command} add data/$engine_1.json
sleep $sleep_seconds
${harness_command} add data/$engine_2.json
${harness_command} status
${harness_command} status engines ${engine_1}
${harness_command} status engines ${engine_2}

# The test is to create 2 engines, 2 users with tag preference behavioral data convert on the same variant in one engine and
# only one user converts on a variant on the second engine. both engines should return the same variant for both users
# because tag preferences are in common is in common.

echo "Sending events to create testGroup: 1, user: joe, and one conversion event with no contextualTags to test_cb"
#mvn compile
# mvn exec:java -Dexec.mainClass="EventsClientExample" -Dexec.args="$1 $2 $3" -Dexec.cleanupDaemonThreads=false
#mvn exec:java -Dexec.mainClass="EventsClientExample" -Dexec.args="$host $engine_1 data/joe-context-tags-2.json" -Dexec.cleanupDaemonThreads=false

echo "Sending events to create testGroup: 1, user: john, and one conversion event with no contextualTags to test_cb_2"
#mvn exec:java -Dexec.mainClass="EventsClientExample" -Dexec.args="$host $engine_1 data/john-context-tags-2.json" -Dexec.cleanupDaemonThreads=false

echo "Sending events to create testGroup: 1, user: john, and one conversion event with no contextualTags to test_cb_2"
#mvn exec:java -Dexec.mainClass="EventsClientExample" -Dexec.args="$host $engine_2 data/joe-context-tags-2.json" -Dexec.cleanupDaemonThreads=false

echo "================================== Behavior queries =================================="
echo "================================== Behavior queries ==================================" > test-behavior-results.txt
echo
echo "Sending queries for joe and john to test_cb"
echo

#mvn exec:java -Dexec.mainClass="QueriesClientExample" -Dexec.args="$host $engine_1 data/2-user-query.json" -Dexec.cleanupDaemonThreads=false >> test-behavior-results.txt

echo
echo "Sending queries for joe and john to test_cb_2"
echo
#mvn exec:java -Dexec.mainClass="QueriesClientExample" -Dexec.args="$host $engine_2 data/2-user-query.json" -Dexec.cleanupDaemonThreads=false >> test-behavior-results.txt
END

echo "---------------------- all differences  ----------------------------"
diff ${actual_results_file} ${test_dir}/expected-cb-test-results.txt | grep Results
echo
