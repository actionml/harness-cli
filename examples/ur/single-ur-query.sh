#!/usr/bin/env bash

curl -H "Content-Type: application/json" -d '
{
  "item": "non-existent item"
}' http://localhost:9090/engines/test_ur/queries
echo

