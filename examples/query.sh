#!/usr/bin/env bash

curl -H "Content-Type: application/json" -d '
{
  "item": "954"
}' http://tbs:9090/engines/tbs/queries
