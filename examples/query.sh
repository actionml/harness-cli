#!/usr/bin/env bash

echo
curl -H "Content-Type: application/json" -d '
{
  "item": "Galaxy 8"
}' http://localhost:9090/engines/test_ur/queries

echo
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["Galaxy 8"]
}' http://localhost:9090/engines/test_ur/queries

echo
curl -H "Content-Type: application/json" -d '
{
  "itemSet": ["Galaxy 8", "Galaxy 8"]
}' http://localhost:9090/engines/test_ur/queries
