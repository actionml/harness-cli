#!/usr/bin/env bash

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "num": 200
}' http://localhost:9090/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "eventNames": ["category-pref"],
  "num": 200
}' http://localhost:9090/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "eventNames": ["purchase"],
  "num": 200
}' http://localhost:9090/engines/test_ur/queries
echo

curl -H "Content-Type: application/json" -d '
{
  "user": "U 2",
  "eventNames": ["view"],
  "num": 200
}' http://localhost:9090/engines/test_ur/queries
echo
