#!/usr/bin/env bash
# Usage 2-user-query.sh host engine-id

host=$1
engine_id=$2

echo "Host: $host"
echo "Engine: $engine_id"

curl -H "Content-Type: application/json" -d '
{
    "user": "joe",
    "groupId": "1"
}' ${host}/engines/${engine_id}/queries
echo

curl -H "Content-Type: application/json" -d '
{
    "user": "john",
    "groupId": "1"
}' ${host}/engines/${engine_id}/queries
echo

#{"user":"joe","groupId":"1"}
#{"user":"john","groupId":"1"}
