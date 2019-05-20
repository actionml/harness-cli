#!/usr/bin/env bash

#harness-cli delete test_cb_1
#harness-cli delete test_cb_2


harness-cli add /Users/pat/harness-cli/examples/cb/test_cb_1.json
harness-cli import test_cb_1 /Users/pat/harness-cli/examples/cb/joe-profile-location.json
sleep 2
harness-cli import test_cb_1 /Users/pat/harness-cli/examples/cb/john-profile-location.json
sleep 2
./examples/cb/2-user-query.sh http://localhost:9090 test_cb_1
sleep 10


harness-cli add /Users/pat/harness-cli/examples/cb/test_cb_2.json
harness-cli import test_cb_2 /Users/pat/harness-cli/examples/cb/joe-profile-location.json
sleep 2
harness-cli import test_cb_2 /Users/pat/harness-cli/examples/cb/john-profile-location.json
sleep 2
./examples/cb/2-user-query.sh http://localhost:9090 test_cb_2
sleep 10


#harness-cli delete test_cb_1
#harness-cli delete test_cb_2
