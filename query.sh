#!/usr/bin/env bash
curl -H "Content-Type: application/json" -d '
{
   "event":"$delete",
   "entityType":"item",
   "entityId":"iPhone XS",
   "eventTime" : "2016-10-05T21:02:49.228Z"
}' http://localhost:9090/engines/test_ur/events
